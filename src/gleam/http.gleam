//// Functions for working with HTTP data structures in Gleam.
////
//// This module makes it easy to create and modify Requests and Responses, data types.
//// A general HTTP message type is defined that enables functions to work on both requests and responses.
////
//// This module does not implement a HTTP client or HTTP server, but it can be used as a base for them.

import gleam/bit_array
import gleam/bool
import gleam/list
import gleam/result
import gleam/string

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

pub fn parse_method(method: String) -> Result(Method, Nil) {
  case method {
    "CONNECT" -> Ok(Connect)
    "DELETE" -> Ok(Delete)
    "GET" -> Ok(Get)
    "HEAD" -> Ok(Head)
    "OPTIONS" -> Ok(Options)
    "PATCH" -> Ok(Patch)
    "POST" -> Ok(Post)
    "PUT" -> Ok(Put)
    "TRACE" -> Ok(Trace)
    method ->
      case is_valid_token(method) {
        True -> Ok(Other(method))
        False -> Error(Nil)
      }
  }
}

// A token is defined as:
//
//   token         = 1*tchar
//
//   tchar         = "!" / "#" / "$" / "%" / "&" / "'" / "*"
//                 / "+" / "-" / "." / "^" / "_" / "`" / "|" / "~"
//                 / DIGIT / ALPHA
//                 ; any VCHAR, except delimiters
//
// (From https://www.rfc-editor.org/rfc/rfc9110.html#name-tokens)
//
// Where DIGIT = %x30-39
//       ALPHA = %x41-5A / %x61-7A
// (%xXX is a hexadecimal ASCII value)
//
// (From https://www.rfc-editor.org/rfc/rfc5234#appendix-B.1)
//
fn is_valid_token(token: String) -> Bool {
  case token {
    // A token must have at least a single valid characther
    "" -> False
    _ -> is_valid_token_loop(token)
  }
}

fn is_valid_token_loop(token: String) -> Bool {
  case token {
    "" -> True
    // SYMBOLS
    "!" <> rest
    | "#" <> rest
    | "$" <> rest
    | "%" <> rest
    | "&" <> rest
    | "'" <> rest
    | "*" <> rest
    | "+" <> rest
    | "-" <> rest
    | "." <> rest
    | "^" <> rest
    | "_" <> rest
    | "`" <> rest
    | "|" <> rest
    | "~" <> rest
    | // DIGITS
      "0" <> rest
    | "1" <> rest
    | "2" <> rest
    | "3" <> rest
    | "4" <> rest
    | "5" <> rest
    | "6" <> rest
    | "7" <> rest
    | "8" <> rest
    | "9" <> rest
    | // ALPHA
      "A" <> rest
    | "B" <> rest
    | "C" <> rest
    | "D" <> rest
    | "E" <> rest
    | "F" <> rest
    | "G" <> rest
    | "H" <> rest
    | "I" <> rest
    | "J" <> rest
    | "K" <> rest
    | "L" <> rest
    | "M" <> rest
    | "N" <> rest
    | "O" <> rest
    | "P" <> rest
    | "Q" <> rest
    | "R" <> rest
    | "S" <> rest
    | "T" <> rest
    | "U" <> rest
    | "V" <> rest
    | "W" <> rest
    | "X" <> rest
    | "Y" <> rest
    | "Z" <> rest
    | "a" <> rest
    | "b" <> rest
    | "c" <> rest
    | "d" <> rest
    | "e" <> rest
    | "f" <> rest
    | "g" <> rest
    | "h" <> rest
    | "i" <> rest
    | "j" <> rest
    | "k" <> rest
    | "l" <> rest
    | "m" <> rest
    | "n" <> rest
    | "o" <> rest
    | "p" <> rest
    | "q" <> rest
    | "r" <> rest
    | "s" <> rest
    | "t" <> rest
    | "u" <> rest
    | "v" <> rest
    | "w" <> rest
    | "x" <> rest
    | "y" <> rest
    | "z" <> rest -> is_valid_token_loop(rest)
    _ -> False
  }
}

pub fn method_to_string(method: Method) -> String {
  case method {
    Connect -> "CONNECT"
    Delete -> "DELETE"
    Get -> "GET"
    Head -> "HEAD"
    Options -> "OPTIONS"
    Patch -> "PATCH"
    Post -> "POST"
    Put -> "PUT"
    Trace -> "TRACE"
    Other(method) -> method
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
/// ```gleam
/// assert "http" == scheme_to_string(Http)
/// assert "https" == scheme_to_string(Https)
/// ```
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
/// ```gleam
/// assert Ok(Http) == scheme_from_string("http")
/// assert Error(Nil) == scheme_from_string("ftp")
/// ```
///
pub fn scheme_from_string(scheme: String) -> Result(Scheme, Nil) {
  case string.lowercase(scheme) {
    "http" -> Ok(Http)
    "https" -> Ok(Https)
    _ -> Error(Nil)
  }
}

pub type MultipartHeaders {
  /// The headers for the part have been fully parsed.
  /// Header keys are all lowercase.
  MultipartHeaders(
    headers: List(Header),
    /// The remaining content that has not yet been parsed. This will contain
    /// the body for this part, if any, and can be parsed with the
    /// `parse_multipart_body` function.
    remaining: BitArray,
  )
  /// More input is required to parse the headers for this part.
  MoreRequiredForHeaders(
    /// Call this function to continue parsing the headers for this part.
    continuation: fn(BitArray) -> Result(MultipartHeaders, Nil),
  )
}

pub type MultipartBody {
  /// The body for the part has been fully parsed.
  MultipartBody(
    // The rest of the body for this part. The full body of the part is this
    // concatenated onto the end of each chunk returned by any previous
    // `MoreRequiredForBody` returns.
    chunk: BitArray,
    /// This is `True` if this was the last part in the multipart message,
    /// otherwise there are more parts to parse.
    done: Bool,
    /// The remaining content that has not yet been parsed. This will contain
    /// the next part if `done` is `False`, otherwise it will contain the
    /// epilogue, if any.
    remaining: BitArray,
  )
  MoreRequiredForBody(
    // The body that has been parsed so far. The full body of the part is this
    // concatenated with the chunk returned by each `MoreRequiredForBody` return
    // value, and the final `MultipartBody` return value.
    chunk: BitArray,
    /// Call this function to continue parsing the body for this part.
    continuation: fn(BitArray) -> Result(MultipartBody, Nil),
  )
}

/// Parse the headers for part of a multipart message, as defined in RFC 2045.
///
/// This function skips any preamble before the boundary. The preamble may be
/// retrieved using `parse_multipart_body`.
///
/// This function will accept input of any size, it is up to the caller to limit
/// it if needed.
///
/// To enable streaming parsing of multipart messages, this function will return
/// a continuation if there is not enough data to fully parse the headers.
/// Further information is available in the documentation for `MultipartBody`.
///
pub fn parse_multipart_headers(
  data: BitArray,
  boundary: String,
) -> Result(MultipartHeaders, Nil) {
  let boundary = bit_array.from_string(boundary)
  let boundary_bytes = bit_array.byte_size(boundary)
  do_parse_multipart_headers(data, boundary, boundary_bytes)
}

fn do_parse_multipart_headers(
  data: BitArray,
  boundary: BitArray,
  boundary_bytes: Int,
) -> Result(MultipartHeaders, Nil) {
  case data {
    // The headers start right away with a boundary.
    <<"--", found:size(boundary_bytes)-bytes, rest:bits>> if found == boundary ->
      case rest {
        // Final boundary `--boundary--`.
        <<"--", rest:bits>> -> Ok(MultipartHeaders([], remaining: rest))

        // Regular boundary `--boundary`.
        <<_, _, _:bits>> -> do_parse_headers(rest)

        // Not enough bytes to make a choice, we have to wait for more.
        _ ->
          more_please_headers(data, fn(data) {
            do_parse_multipart_headers(data, boundary, boundary_bytes)
          })
      }

    // The headers start with a preamble we need to skip.
    _ -> skip_preamble(data, boundary, boundary_bytes)
  }
}

fn skip_preamble(
  data: BitArray,
  boundary: BitArray,
  boundary_bytes: Int,
) -> Result(MultipartHeaders, Nil) {
  case data {
    // We might have found the preamble end!
    <<"\r\n--", rest:bytes>> -> {
      case rest {
        // It is indeed the end, we go on parsing the headers that come after
        // the boundary.
        <<found:size(boundary_bytes)-bytes, rest:bits>> if found == boundary ->
          do_parse_headers(rest)

        // This was not the end because `\r\n--` is not followed by the expected
        // boundary, so we keep ignoring bytes.
        <<_found:size(boundary_bytes)-bytes, _:bits>> ->
          skip_preamble(rest, boundary, boundary_bytes)

        // There's not enough bytes to make sure the `\r\n--` is not followed
        // by the closing boundary so we have to wait for more to come.
        _ ->
          more_please_headers(data, skip_preamble(_, boundary, boundary_bytes))
      }
    }

    // We don't have enough bytes to be sure this is not the end of the preamble
    // so we have to wait for more to come.
    <<>> | <<"\r">> | <<"\r\n">> | <<"\r\n-">> ->
      more_please_headers(data, skip_preamble(_, boundary, boundary_bytes))

    // The byte is surely part of the preamble and can be skipped.
    <<_, data:bytes>> -> skip_preamble(data, boundary, boundary_bytes)

    _ -> panic as "unreachable"
  }
}

fn do_parse_headers(data: BitArray) -> Result(MultipartHeaders, Nil) {
  case data {
    // We've reached the end, there are no headers.
    <<"\r\n\r\n", data:bytes>> -> Ok(MultipartHeaders([], remaining: data))

    // Skip the line break after the boundary.
    <<"\r\n", data:bytes>> -> parse_header_name(data, [])

    <<"\r">> | <<>> -> more_please_headers(data, do_parse_headers)

    _ -> Error(Nil)
  }
}

fn parse_header_name(
  data: BitArray,
  headers: List(Header),
) -> Result(MultipartHeaders, Nil) {
  case data {
    // We first have to skip all whitespace preceding the name.
    <<" ", rest:bits>> | <<"\t", rest:bits>> -> parse_header_name(rest, headers)
    <<_, _:bits>> -> parse_header_name_loop(data, headers, <<>>)

    // We don't have enough bits to make a choice and will have to wait for more
    // to come.
    _ -> more_please_headers(data, parse_header_name(_, headers))
  }
}

fn parse_header_name_loop(data: BitArray, headers: List(Header), name: BitArray) {
  case data {
    // We've found the end of the header, we can now start parsing its value.
    <<":", data:bits>> ->
      case bit_array.to_string(name) {
        Ok(name) -> parse_header_value(data, headers, name)
        Error(Nil) -> Error(Nil)
      }

    // Otherwise the character belongs to the header.
    <<char, data:bits>> ->
      parse_header_name_loop(data, headers, <<name:bits, char>>)

    // We don't have enough bits to make a choice and have to wait for more to
    // come.
    _ -> more_please_headers(data, parse_header_name_loop(_, headers, name))
  }
}

fn parse_header_value(data: BitArray, headers: List(Header), name: String) {
  case data {
    // We first have to skip all whitespace preceding the value.
    <<" ", rest:bits>> | <<"\t", rest:bits>> ->
      parse_header_value(rest, headers, name)

    <<_, _:bits>> -> parse_header_value_loop(data, headers, name, <<>>)

    // We don't have enough bits to make a choice and will have to wait for more
    // to come.
    _ -> more_please_headers(data, parse_header_value(_, headers, name))
  }
}

fn parse_header_value_loop(
  data: BitArray,
  headers: List(Header),
  name: String,
  value: BitArray,
) -> Result(MultipartHeaders, Nil) {
  case data {
    // We need at least 4 bytes to check for the end of the headers.
    <<>> | <<_>> | <<_, _>> | <<_, _, _>> ->
      more_please_headers(data, fn(data) {
        parse_header_value_loop(data, headers, name, value)
      })

    <<"\r\n\r\n", data:bytes>> -> {
      use value <- result.map(bit_array.to_string(value))
      let headers = list.reverse([#(string.lowercase(name), value), ..headers])
      MultipartHeaders(headers:, remaining: data)
    }

    <<"\r\n ", data:bytes>> | <<"\r\n\t", data:bytes>> ->
      parse_header_value_loop(data, headers, name, value)

    <<"\r\n", data:bytes>> -> {
      use value <- result.try(bit_array.to_string(value))
      let headers = [#(string.lowercase(name), value), ..headers]
      parse_header_name(data, headers)
    }

    <<char, rest:bytes>> ->
      parse_header_value_loop(rest, headers, name, <<value:bits, char>>)

    _ -> Error(Nil)
  }
}

/// Parse the body for part of a multipart message, as defined in RFC 2045. The
/// body is everything until the next boundary. This function is generally to be
/// called after calling `parse_multipart_headers` for a given part.
///
/// This function will accept input of any size, it is up to the caller to limit
/// it if needed.
///
/// To enable streaming parsing of multipart messages, this function will return
/// a continuation if there is not enough data to fully parse the body, along
/// with the data that has been parsed so far. Further information is available
/// in the documentation for `MultipartBody`.
///
pub fn parse_multipart_body(
  data: BitArray,
  boundary: String,
) -> Result(MultipartBody, Nil) {
  let boundary = bit_array.from_string(boundary)
  let boundary_bytes = bit_array.byte_size(boundary)
  do_parse_multipart_body(data, boundary, boundary_bytes)
}

fn do_parse_multipart_body(
  data: BitArray,
  boundary: BitArray,
  boundary_bytes: Int,
) -> Result(MultipartBody, Nil) {
  case data {
    <<"--", found:size(boundary_bytes)-bytes, _:bits>> if found == boundary ->
      Ok(MultipartBody(<<>>, done: False, remaining: data))
    _ -> parse_body_loop(data, boundary, <<>>)
  }
}

fn parse_body_loop(
  data: BitArray,
  boundary: BitArray,
  body: BitArray,
) -> Result(MultipartBody, Nil) {
  let dsize = bit_array.byte_size(data)
  let bsize = bit_array.byte_size(boundary)
  let required = 6 + bsize
  case data {
    _ if dsize < required ->
      more_please_body(body, data, parse_body_loop(_, boundary, <<>>))

    // TODO: flatten this into a single case expression once JavaScript supports
    // the `b:binary-size(bsize)` pattern.
    //
    // \r\n
    <<13, 10, data:bytes>> -> {
      let desired = <<45, 45, boundary:bits>>
      let size = bit_array.byte_size(desired)
      let dsize = bit_array.byte_size(data)
      let prefix = bit_array.slice(data, 0, size)
      let rest = bit_array.slice(data, size, dsize - size)
      case prefix == Ok(desired), rest {
        // --boundary\r\n
        True, Ok(<<13, 10, _:bytes>>) ->
          Ok(MultipartBody(body, done: False, remaining: data))

        // --boundary--
        True, Ok(<<45, 45, data:bytes>>) ->
          Ok(MultipartBody(body, done: True, remaining: data))

        False, _ -> parse_body_loop(data, boundary, <<body:bits, 13, 10>>)
        _, _ -> Error(Nil)
      }
    }

    <<char, data:bytes>> -> {
      parse_body_loop(data, boundary, <<body:bits, char>>)
    }

    _ -> panic as "unreachable"
  }
}

fn more_please_headers(
  existing: BitArray,
  continuation: fn(BitArray) -> Result(MultipartHeaders, Nil),
) -> Result(MultipartHeaders, Nil) {
  Ok(
    MoreRequiredForHeaders(fn(more) {
      use <- bool.guard(more == <<>>, return: Error(Nil))
      continuation(<<existing:bits, more:bits>>)
    }),
  )
}

fn more_please_body(
  chunk: BitArray,
  existing: BitArray,
  continuation: fn(BitArray) -> Result(MultipartBody, Nil),
) -> Result(MultipartBody, Nil) {
  Ok(
    MoreRequiredForBody(chunk, fn(more) {
      use <- bool.guard(more == <<>>, return: Error(Nil))
      continuation(<<existing:bits, more:bits>>)
    }),
  )
}

pub type ContentDisposition {
  ContentDisposition(String, parameters: List(#(String, String)))
}

pub fn parse_content_disposition(
  header: String,
) -> Result(ContentDisposition, Nil) {
  parse_content_disposition_type(header, "")
}

fn parse_content_disposition_type(
  header: String,
  name: String,
) -> Result(ContentDisposition, Nil) {
  case string.pop_grapheme(header) {
    Error(Nil) -> Ok(ContentDisposition(name, []))

    Ok(#(" ", rest)) | Ok(#("\t", rest)) | Ok(#(";", rest)) -> {
      let result = parse_rfc_2045_parameters(rest, [])
      use parameters <- result.map(result)
      ContentDisposition(name, parameters)
    }

    Ok(#(grapheme, rest)) ->
      parse_content_disposition_type(rest, name <> string.lowercase(grapheme))
  }
}

fn parse_rfc_2045_parameters(
  header: String,
  parameters: List(#(String, String)),
) -> Result(List(#(String, String)), Nil) {
  case string.pop_grapheme(header) {
    Error(Nil) -> Ok(list.reverse(parameters))

    Ok(#(";", rest)) | Ok(#(" ", rest)) | Ok(#("\t", rest)) ->
      parse_rfc_2045_parameters(rest, parameters)

    Ok(#(grapheme, rest)) -> {
      let acc = string.lowercase(grapheme)
      use #(parameter, rest) <- result.try(parse_rfc_2045_parameter(rest, acc))
      parse_rfc_2045_parameters(rest, [parameter, ..parameters])
    }
  }
}

fn parse_rfc_2045_parameter(
  header: String,
  name: String,
) -> Result(#(#(String, String), String), Nil) {
  use #(grapheme, rest) <- result.try(string.pop_grapheme(header))
  case grapheme {
    "=" -> parse_rfc_2045_parameter_value(rest, name)
    _ -> parse_rfc_2045_parameter(rest, name <> string.lowercase(grapheme))
  }
}

fn parse_rfc_2045_parameter_value(
  header: String,
  name: String,
) -> Result(#(#(String, String), String), Nil) {
  case string.pop_grapheme(header) {
    Error(Nil) -> Error(Nil)
    Ok(#("\"", rest)) -> parse_rfc_2045_parameter_quoted_value(rest, name, "")
    Ok(#(grapheme, rest)) ->
      Ok(parse_rfc_2045_parameter_unquoted_value(rest, name, grapheme))
  }
}

fn parse_rfc_2045_parameter_quoted_value(
  header: String,
  name: String,
  value: String,
) -> Result(#(#(String, String), String), Nil) {
  case string.pop_grapheme(header) {
    Error(Nil) -> Error(Nil)
    Ok(#("\"", rest)) -> Ok(#(#(name, value), rest))
    Ok(#("\\", rest)) -> {
      use #(grapheme, rest) <- result.try(string.pop_grapheme(rest))
      parse_rfc_2045_parameter_quoted_value(rest, name, value <> grapheme)
    }
    Ok(#(grapheme, rest)) ->
      parse_rfc_2045_parameter_quoted_value(rest, name, value <> grapheme)
  }
}

fn parse_rfc_2045_parameter_unquoted_value(
  header: String,
  name: String,
  value: String,
) -> #(#(String, String), String) {
  case string.pop_grapheme(header) {
    Error(Nil) -> #(#(name, value), header)

    Ok(#(";", rest)) | Ok(#(" ", rest)) | Ok(#("\t", rest)) -> #(
      #(name, value),
      rest,
    )

    Ok(#(grapheme, rest)) ->
      parse_rfc_2045_parameter_unquoted_value(rest, name, value <> grapheme)
  }
}

/// A HTTP header is a key-value pair. Header keys must be all lowercase
/// characters.
pub type Header =
  #(String, String)
