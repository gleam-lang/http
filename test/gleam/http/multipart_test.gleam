import gleeunit/should
import gleam/bit_string
import gleam/list
import gleam/http/multipart.{MoreForHeaders, ParsedHeaders}

pub fn parse_headers_1_test() {
  let input = <<
    "--frontier\r
Content-Type: text/plain\r
\r
This is the body of the message.\r
--frontier\r
":utf8,
  >>

  let assert Ok(ParsedHeaders(headers, rest)) =
    multipart.parse_headers(input, "frontier")

  headers
  |> should.equal([#("content-type", "text/plain")])
  rest
  |> should.equal(<<"This is the body of the message.\r\n--frontier\r\n":utf8>>)
}

pub fn parse_headers_2_test() {
  let input = <<
    "--frontier\r
Content-Type: application/octet-stream\r
Content-Transfer-Encoding: base64\r
\r
PGh0bWw+CiAgPGhlYWQ+CiAgPC9oZWFkPgogIDxib2R5PgogICAgPHA+VGhpcyBpcyB0aGUg\r
Ym9keSBvZiB0aGUgbWVzc2FnZS48L3A+CiAgPC9ib2R5Pgo8L2h0bWw+Cg==\r
--frontier--":utf8,
  >>

  let assert Ok(ParsedHeaders(headers, rest)) =
    multipart.parse_headers(input, "frontier")

  headers
  |> should.equal([
    #("content-type", "application/octet-stream"),
    #("content-transfer-encoding", "base64"),
  ])
  rest
  |> should.equal(<<
    "PGh0bWw+CiAgPGhlYWQ+CiAgPC9oZWFkPgogIDxib2R5PgogICAgPHA+VGhpcyBpcyB0aGUg\r
Ym9keSBvZiB0aGUgbWVzc2FnZS48L3A+CiAgPC9ib2R5Pgo8L2h0bWw+Cg==\r\n--frontier--":utf8,
  >>)
}

pub fn parse_headers_not_enough_input_1_test() {
  let input = <<
    "--frontier\r
Content-Type: text/":utf8,
  >>

  let assert Ok(MoreForHeaders(continue)) =
    multipart.parse_headers(input, "frontier")
  let assert Ok(MoreForHeaders(continue)) = continue(<<"plai":utf8>>)

  let assert Ok(ParsedHeaders(headers, rest)) =
    continue(<<"n\r\n\r\nblah":utf8>>)

  headers
  |> should.equal([#("content-type", "text/plain")])
  rest
  |> should.equal(<<"blah":utf8>>)
}

pub fn parse_headers_not_enough_input_2_test() {
  let input = <<
    "--frontier\r
Content-Type: text/plain\r":utf8,
  >>

  let assert Ok(MoreForHeaders(continue)) =
    multipart.parse_headers(input, "frontier")
  let assert Ok(ParsedHeaders(headers, rest)) = continue(<<"\n\r\nblah":utf8>>)

  headers
  |> should.equal([#("content-type", "text/plain")])
  rest
  |> should.equal(<<"blah":utf8>>)
}

pub fn parse_headers_not_enough_input_3_test() {
  let input = <<
    "--frontier\r
Content-Ty":utf8,
  >>

  let assert Ok(MoreForHeaders(continue)) =
    multipart.parse_headers(input, "frontier")
  let assert Ok(ParsedHeaders(headers, rest)) =
    continue(<<"pe: text/plain\r\n\r\nblah":utf8>>)

  headers
  |> should.equal([#("content-type", "text/plain")])
  rest
  |> should.equal(<<"blah":utf8>>)
}

pub fn parse_headers_not_enough_input_4_test() {
  let input = <<"--":utf8>>

  let assert Ok(MoreForHeaders(continue)) =
    multipart.parse_headers(input, "frontier")
  let assert Ok(ParsedHeaders(headers, rest)) =
    continue(<<
      "frontier\r
Content-Type: text/plain\r\n\r\nblah":utf8,
    >>)

  headers
  |> should.equal([#("content-type", "text/plain")])
  rest
  |> should.equal(<<"blah":utf8>>)
}

/// This test uses the `slices` function to split the input into every possible
/// pair of bit-strings and then parses the headers from each pair.
/// This ensures that no matter where the input gets chunked the parser will
/// return the same result.
pub fn parse_headers_chunked_test() {
  let input = <<
    "--frontier\r
Content-Type: text/plain\r
\r
This is the body of the message.\r
--frontier\r
":utf8,
  >>
  use #(before, after) <- list.each(slices(<<>>, input, []))

  let assert Ok(return) = multipart.parse_headers(before, "frontier")

  let assert Ok(ParsedHeaders(headers, rest)) = case return {
    MoreForHeaders(continue) -> continue(after)
    ParsedHeaders(headers, remaining) ->
      Ok(ParsedHeaders(headers, bit_string.append(remaining, after)))
  }

  headers
  |> should.equal([#("content-type", "text/plain")])
  rest
  |> should.equal(<<
    "This is the body of the message.\r
--frontier\r
":utf8,
  >>)
}

fn slices(
  before: BitString,
  after: BitString,
  acc: List(#(BitString, BitString)),
) -> List(#(BitString, BitString)) {
  case after {
    <<first, rest:binary>> ->
      slices(<<before:bit_string, first>>, rest, [#(before, after), ..acc])
    <<>> -> [#(before, after), ..acc]
  }
}

pub fn slices_test() {
  slices(<<>>, <<"abcde":utf8>>, [])
  |> should.equal([
    #(<<"abcde":utf8>>, <<"":utf8>>),
    #(<<"abcd":utf8>>, <<"e":utf8>>),
    #(<<"abc":utf8>>, <<"de":utf8>>),
    #(<<"ab":utf8>>, <<"cde":utf8>>),
    #(<<"a":utf8>>, <<"bcde":utf8>>),
    #(<<>>, <<"abcde":utf8>>),
  ])
}
