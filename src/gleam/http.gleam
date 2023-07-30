//// Functions for working with HTTP data structures in Gleam.
////
//// This module makes it easy to create and modify Requests and Responses, data types.
//// A general HTTP message type is defined that enables functions to work on both requests and responses.
////
//// This module does not implement a HTTP client or HTTP server, but it can be used as a base for them.

import gleam/dynamic.{DecodeError, Dynamic}
import gleam/string
import gleam/bit_string
import gleam/result
import gleam/list
import gleam/bool

/// HTTP standard method as defined by [RFC 2616](https://tools.ietf.org/html/rfc2616),
/// and PATCH which is defined by [RFC 5789](https://tools.ietf.org/html/rfc5789).
pub type Method {
  Get
  Post
  Head
  Put
  Delete
  Trace
  Connect
  Options
  Patch

  /// Non-standard but valid HTTP methods.
  Other(String)
}

// TODO: check if the a is a valid HTTP method (i.e. it is a token, as per the
// spec) and return Ok(Other(s)) if so.
pub fn parse_method(s) -> Result(Method, Nil) {
  case string.lowercase(s) {
    "connect" -> Ok(Connect)
    "delete" -> Ok(Delete)
    "get" -> Ok(Get)
    "head" -> Ok(Head)
    "options" -> Ok(Options)
    "patch" -> Ok(Patch)
    "post" -> Ok(Post)
    "put" -> Ok(Put)
    "trace" -> Ok(Trace)
    _ -> Error(Nil)
  }
}

pub fn method_to_string(method: Method) -> String {
  case method {
    Connect -> "connect"
    Delete -> "delete"
    Get -> "get"
    Head -> "head"
    Options -> "options"
    Patch -> "patch"
    Post -> "post"
    Put -> "put"
    Trace -> "trace"
    Other(s) -> s
  }
}

/// The two URI schemes for HTTP
///
pub type Scheme {
  Http
  Https
}

/// Convert a scheme into a string.
///
/// # Examples
///
///    > scheme_to_string(Http)
///    "http"
///
///    > scheme_to_string(Https)
///    "https"
///
pub fn scheme_to_string(scheme: Scheme) -> String {
  case scheme {
    Http -> "http"
    Https -> "https"
  }
}

/// Parse a HTTP scheme from a string
///
/// # Examples
///
///    > scheme_to_string("http")
///    Ok(Http)
///
///    > scheme_to_string("ftp")
///    Error(Nil)
///
pub fn scheme_from_string(scheme: String) -> Result(Scheme, Nil) {
  case string.lowercase(scheme) {
    "http" -> Ok(Http)
    "https" -> Ok(Https)
    _ -> Error(Nil)
  }
}

pub fn method_from_dynamic(value: Dynamic) -> Result(Method, List(DecodeError)) {
  case do_method_from_dynamic(value) {
    Ok(method) -> Ok(method)
    Error(_) -> Error([DecodeError("HTTP method", dynamic.classify(value), [])])
  }
}

pub type Multipart(t) {
  Part(t, remaining: BitString)
  Done(t, remaining: BitString)
  MoreRequired(fn(BitString) -> Result(Multipart(t), Nil))
}

/// Parse the headers for the next multipart part.
///
/// This function is used for parsing the multipart format is defined in
/// RFC 2045, along with `parse_multipart_body`.
///
/// This function skips any preamble before the boundary. The preamble may be
/// retrieved using `parse_body`.
///
/// This function will accept input of any size, it is up to the caller to limit
/// it if needed.
/// 
pub fn parse_multipart_headers(
  data: BitString,
  boundary: String,
) -> Result(Multipart(List(Header)), Nil) {
  let boundary = bit_string.from_string(boundary)
  // TODO: rewrite this to use a bit pattern once JavaScript supports
  // the `b:binary-size(bsize)` pattern.
  let prefix = <<45, 45, boundary:bit_string>>
  case bit_string.slice(data, 0, bit_string.byte_size(prefix)) == Ok(prefix) {
    // There is no preamble, parse the headers.
    True -> parse_headers_after_prelude(data, boundary)
    // There is a preamble, skip it before parsing.
    False -> skip_preamble(data, boundary)
  }
}

/// Parse the body of the current multipart part, which is everything until the
/// next boundary.
/// 
/// This function is used for parsing the multipart format is defined in
/// RFC 2045, along with `parse_multipart_headers`.
///
/// This function will accept input of any size, it is up to the caller to limit
/// it if needed.
/// 
pub fn parse_multipart_body(
  data: BitString,
  boundary: String,
) -> Result(Multipart(String), Nil) {
  let boundary = bit_string.from_string(boundary)
  parse_body_with_bit_string(data, boundary)
}

fn parse_body_with_bit_string(
  data: BitString,
  boundary: BitString,
) -> Result(Multipart(String), Nil) {
  let bsize = bit_string.byte_size(boundary)
  let prefix = bit_string.slice(data, 0, 2 + bsize)
  case prefix == Ok(<<45, 45, boundary:bit_string>>) {
    True -> Ok(Part("", remaining: data))
    False -> parse_body_loop(data, boundary, <<>>)
  }
}

fn parse_body_loop(
  data: BitString,
  boundary: BitString,
  body: BitString,
) -> Result(Multipart(String), Nil) {
  let dsize = bit_string.byte_size(data)
  let bsize = bit_string.byte_size(boundary)
  let required = 6 + bsize
  case data {
    _ if dsize < required -> {
      more_please(parse_body_loop(_, boundary, body), data)
    }

    // TODO: flatten this into a single case expression once JavaScript supports
    // the `b:binary-size(bsize)` pattern.
    //
    // \r\n
    <<13, 10, data:binary>> -> {
      let desired = <<45, 45, boundary:bit_string>>
      let size = bit_string.byte_size(desired)
      let dsize = bit_string.byte_size(data)
      let prefix = bit_string.slice(data, 0, size)
      let rest = bit_string.slice(data, size, dsize - size)
      case prefix == Ok(desired), rest {
        // --boundary\r\n
        True, Ok(<<13, 10, _:binary>>) -> {
          use body <- result.map(bit_string.to_string(body))
          Part(body, remaining: data)
        }

        // --boundary--
        True, Ok(<<45, 45, data:binary>>) -> {
          use body <- result.map(bit_string.to_string(body))
          Done(body, remaining: data)
        }
        False, _ -> parse_body_loop(data, boundary, <<body:bit_string, 13, 10>>)
        _, _ -> Error(Nil)
      }
    }

    <<char, data:binary>> -> {
      parse_body_loop(data, boundary, <<body:bit_string, char>>)
    }
  }
}

fn parse_headers_after_prelude(
  data: BitString,
  boundary: BitString,
) -> Result(Multipart(List(Header)), Nil) {
  let dsize = bit_string.byte_size(data)
  let bsize = bit_string.byte_size(boundary)
  let required_size = bsize + 4

  // TODO: this could be written as a single case expression if JavaScript had
  // support for the `b:binary-size(bsize)` pattern. Rewrite this once the
  // compiler support this.

  use <- bool.guard(
    when: dsize < required_size,
    return: more_please(parse_headers_after_prelude(_, boundary), data),
  )

  use prefix <- result.try(bit_string.slice(data, 0, required_size - 2))
  use second <- result.try(bit_string.slice(data, 2 + bsize, 2))
  let desired = <<45, 45, boundary:bit_string>>

  use <- bool.guard(prefix != desired, return: Error(Nil))

  case second == <<45, 45>> {
    // --boundary--
    // The last boundary. Return the epilogue.
    True -> {
      let rest_size = dsize - required_size
      use data <- result.map(bit_string.slice(data, required_size, rest_size))
      Part([], remaining: data)
    }

    // --boundary
    False -> {
      let start = required_size - 2
      let rest_size = dsize - required_size + 2
      use data <- result.try(bit_string.slice(data, start, rest_size))
      do_parse_headers(data)
    }
  }
}

// TODO: implement
fn skip_preamble(
  data: BitString,
  boundary: BitString,
) -> Result(Multipart(List(Header)), Nil) {
  let data_size = bit_string.byte_size(data)
  let boundary_size = bit_string.byte_size(boundary)
  let required = boundary_size + 4
  case data {
    _ if data_size < required -> more_please(skip_preamble(_, boundary), data)

    // TODO: change this to use one non-nested case expression once the compiler
    // supports the `b:binary-size(bsize)` pattern on JS.
    // \r\n--
    <<13, 10, 45, 45, data:binary>> -> {
      case bit_string.slice(data, 0, boundary_size) {
        // --boundary
        Ok(prefix) if prefix == boundary -> {
          let start = boundary_size
          let length = bit_string.byte_size(data) - boundary_size
          use rest <- result.try(bit_string.slice(data, start, length))
          do_parse_headers(rest)
        }
        Ok(_) -> skip_preamble(data, boundary)
        Error(_) -> Error(Nil)
      }
    }

    <<_, data:binary>> -> skip_preamble(data, boundary)
  }
}

fn skip_whitespace(data: BitString) -> BitString {
  case data {
    // Space or tab.
    <<32, data:binary>> | <<9, data:binary>> -> skip_whitespace(data)
    _ -> data
  }
}

fn do_parse_headers(data: BitString) -> Result(Multipart(List(Header)), Nil) {
  case data {
    // \r\n\r\n
    // We've reached the end, there are no headers.
    <<13, 10, 13, 10, data:binary>> -> Ok(Part([], remaining: data))

    // \r\n
    // Skip the line break after the boundary.
    <<13, 10, data:binary>> -> parse_header_name(data, [], <<>>)

    <<13>> | <<>> -> more_please(do_parse_headers, data)

    _ -> Error(Nil)
  }
}

fn parse_header_name(
  data: BitString,
  headers: List(Header),
  name: BitString,
) -> Result(Multipart(List(Header)), Nil) {
  case skip_whitespace(data) {
    // :
    <<58, data:binary>> ->
      data
      |> skip_whitespace
      |> parse_header_value(headers, name, <<>>)

    <<char, data:binary>> ->
      parse_header_name(data, headers, <<name:bit_string, char>>)

    <<>> -> more_please(parse_header_name(_, headers, name), data)
  }
}

fn parse_header_value(
  data: BitString,
  headers: List(Header),
  name: BitString,
  value: BitString,
) -> Result(Multipart(List(Header)), Nil) {
  let size = bit_string.byte_size(data)
  case data {
    // We need at least 4 bytes to check for the end of the headers.
    _ if size < 4 ->
      fn(data) {
        data
        |> skip_whitespace
        |> parse_header_value(headers, name, value)
      }
      |> more_please(data)

    // \r\n\r\n
    <<13, 10, 13, 10, data:binary>> -> {
      use name <- result.try(bit_string.to_string(name))
      use value <- result.map(bit_string.to_string(value))
      let headers = list.reverse([#(string.lowercase(name), value), ..headers])
      Part(headers, data)
    }

    // \r\n\s
    // \r\n\t
    <<13, 10, 32, data:binary>> | <<13, 10, 9, data:binary>> ->
      parse_header_value(data, headers, name, value)

    // \r\n
    <<13, 10, data:binary>> -> {
      use name <- result.try(bit_string.to_string(name))
      use value <- result.try(bit_string.to_string(value))
      let headers = [#(string.lowercase(name), value), ..headers]
      parse_header_name(data, headers, <<>>)
    }

    <<char, rest:binary>> -> {
      let value = <<value:bit_string, char>>
      parse_header_value(rest, headers, name, value)
    }

    _ -> Error(Nil)
  }
}

fn more_please(
  continuation: fn(BitString) -> Result(Multipart(t), Nil),
  existing: BitString,
) -> Result(Multipart(t), Nil) {
  Ok(MoreRequired(fn(more) {
    use <- bool.guard(more == <<>>, return: Error(Nil))
    continuation(<<existing:bit_string, more:bit_string>>)
  }))
}

@target(erlang)
@external(erlang, "gleam_http_native", "decode_method")
fn do_method_from_dynamic(a: Dynamic) -> Result(Method, nil)

@target(javascript)
@external(javascript, "../gleam_http_native.mjs", "decode_method")
fn do_method_from_dynamic(a: Dynamic) -> Result(Method, Nil)

/// A HTTP header is a key-value pair. Header keys should be all lowercase
/// characters.
pub type Header =
  #(String, String)
