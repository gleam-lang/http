//// Parsing of the multipart format is defined in RFC 2045.
//// 
//// This module was written using Erlang's cowlib and Elixir's Plug as
//// references. Thank you to the maintainers of those projects! 

// TODO: remove the int literals in string patterns once we have better support
// for bit string patterns on JavaScript.

import gleam/bit_string
import gleam/string
import gleam/result
import gleam/list
import gleam/bool

pub type Header =
  #(String, String)

pub type ParsedHeaders {
  ParsedHeaders(headers: List(Header), remaining_input: BitString)
  MoreForHeaders(fn(BitString) -> Result(ParsedHeaders, Nil))
}

/// Parse the headers for the next multipart part.
///
/// This function skips any preamble before the boundary. The preamble may be
/// retrieved using `parse_body`.
///
/// This function will accept input of any size, it is up to the caller to limit
/// it if needed.
/// 
pub fn parse_headers(
  data: BitString,
  boundary: String,
) -> Result(ParsedHeaders, Nil) {
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

fn parse_headers_after_prelude(
  data: BitString,
  boundary: BitString,
) -> Result(ParsedHeaders, Nil) {
  let dsize = bit_string.byte_size(data)
  let bsize = bit_string.byte_size(boundary)
  let required_size = bsize + 4

  // TODO: this could be written as a single case expression if JavaScript had
  // support for the `b:binary-size(bsize)` pattern. Rewrite this once the
  // compiler support this.

  use <- bool.guard(
    when: dsize < required_size,
    return: parse_headers_after_prelude(_, boundary)
    |> more_please(data)
    |> MoreForHeaders
    |> Ok,
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
      ParsedHeaders(headers: [], remaining_input: data)
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
) -> Result(ParsedHeaders, Nil) {
  let data_size = bit_string.byte_size(data)
  let boundary_size = bit_string.byte_size(boundary)
  let required = boundary_size + 4
  case data {
    _ if data_size < required ->
      skip_preamble(_, boundary)
      |> more_please(data)
      |> MoreForHeaders
      |> Ok

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

fn do_parse_headers(data: BitString) -> Result(ParsedHeaders, Nil) {
  case data {
    // \r\n\r\n
    // We've reached the end, there are no headers.
    <<13, 10, 13, 10, data:binary>> ->
      Ok(ParsedHeaders(headers: [], remaining_input: data))

    // \r\n
    // Skip the line break after the boundary.
    <<13, 10, data:binary>> -> parse_header_name(data, [], <<>>)

    <<13>> | <<>> ->
      do_parse_headers
      |> more_please(data)
      |> MoreForHeaders
      |> Ok

    _ -> Error(Nil)
  }
}

fn parse_header_name(
  data: BitString,
  headers: List(Header),
  name: BitString,
) -> Result(ParsedHeaders, Nil) {
  case skip_whitespace(data) {
    // :
    <<58, data:binary>> ->
      data
      |> skip_whitespace
      |> parse_header_value(headers, name, <<>>)

    <<char, data:binary>> ->
      parse_header_name(data, headers, <<name:bit_string, char>>)

    <<>> ->
      parse_header_name(_, headers, name)
      |> more_please(data)
      |> MoreForHeaders
      |> Ok
  }
}

fn parse_header_value(
  data: BitString,
  headers: List(Header),
  name: BitString,
  value: BitString,
) -> Result(ParsedHeaders, Nil) {
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
      |> MoreForHeaders
      |> Ok

    // \r\n\r\n
    <<13, 10, 13, 10, data:binary>> -> {
      use name <- result.try(bit_string.to_string(name))
      use value <- result.map(bit_string.to_string(value))
      let headers = list.reverse([#(string.lowercase(name), value), ..headers])
      ParsedHeaders(headers, data)
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
  continuation: fn(BitString) -> Result(t, Nil),
  existing: BitString,
) -> fn(BitString) -> Result(t, Nil) {
  fn(more) {
    use <- bool.guard(more == <<>>, return: Error(Nil))
    continuation(<<existing:bit_string, more:bit_string>>)
  }
}
