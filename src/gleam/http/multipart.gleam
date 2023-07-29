//// Parsing of the multipart format is defined in RFC 2045.
//// 
//// This module was written using Erlang's cowlib and Elixir's Plug as
//// references. Thank you to the maintainers of those projects! 

import gleam/bit_string
import gleam/string
import gleam/result
import gleam/list

pub type Header =
  #(String, String)

pub type ParsedHeaders {
  ParsedHeaders(headers: List(Header), remaining_input: BitString)
  MoreInputNeededForHeaders(fn(BitString) -> ParsedHeaders)
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
  let data = skip_preamble(data, boundary)
  let bsize = bit_string.byte_size(boundary)
  case data {
    // The last boundary. Return the epilogue.
    <<"--":utf8, b:binary-size(bsize), "--":utf8, data:binary>> if b == boundary ->
      Ok(ParsedHeaders(headers: [], remaining_input: data))

    <<"--":utf8, b:binary-size(bsize), data:binary>> if b == boundary ->
      do_parse_headers(data)
  }
  // TODO: more required
  // TODO: other
}

// TODO: implement
fn skip_preamble(data: BitString, boundary: BitString) -> BitString {
  case data {
    <<"--":utf8, _:binary>> -> data
    _ -> todo as "skip preamble"
  }
}

fn skip_whitespace(data: BitString) -> BitString {
  case data {
    <<" ":utf8, data:binary>> | <<"\t":utf8, data:binary>> ->
      skip_whitespace(data)
    _ -> data
  }
}

fn do_parse_headers(data) -> Result(ParsedHeaders, Nil) {
  case data {
    // We've reached the end, there are no headers.
    <<"\r\n\r\n":utf8, data:binary>> ->
      Ok(ParsedHeaders(headers: [], remaining_input: data))

    // Skip the line break after the boundary.
    <<"\r\n":utf8, data:binary>> -> parse_header_name(data, [], <<>>)

    _ -> Error(Nil)
  }
}

fn parse_header_name(
  data: BitString,
  headers: List(Header),
  name: BitString,
) -> Result(ParsedHeaders, Nil) {
  case skip_whitespace(data) {
    <<":":utf8, data:binary>> ->
      data
      |> skip_whitespace
      |> parse_header_value(headers, name, <<>>)
    <<char:utf8_codepoint, data:binary>> ->
      parse_header_name(data, headers, <<name:bit_string, char:utf8_codepoint>>)
  }
  // TODO: more required
}

fn parse_header_value(
  data: BitString,
  headers: List(Header),
  name: BitString,
  value: BitString,
) -> Result(ParsedHeaders, Nil) {
  case data {
    <<"\r\n\r\n":utf8, data:binary>> -> {
      use name <- result.try(bit_string.to_string(name))
      use value <- result.map(bit_string.to_string(value))
      let headers = list.reverse([#(string.lowercase(name), value), ..headers])
      ParsedHeaders(headers, data)
    }

    <<"\r\n ":utf8, data:binary>> | <<"\r\n\t":utf8, data:binary>> ->
      parse_header_value(data, headers, name, value)

    <<"\r\n":utf8, data:binary>> -> {
      use name <- result.try(bit_string.to_string(name))
      use value <- result.try(bit_string.to_string(value))
      let headers = [#(string.lowercase(name), value), ..headers]
      parse_header_name(data, headers, <<>>)
    }

    <<char:utf8_codepoint, data:binary>> -> {
      let value = <<value:bit_string, char:utf8_codepoint>>
      parse_header_value(data, headers, name, value)
    }
  }
  // TODO: more required
}
