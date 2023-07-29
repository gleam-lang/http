import gleeunit/should
import gleam/bit_string
import gleam/http/multipart.{ParsedHeaders}

pub fn parse_headers_1_test() {
  let input =
    bit_string.from_string(
      "--frontier\r
Content-Type: text/plain\r
\r
This is the body of the message.\r
--frontier\r
",
    )

  let assert Ok(ParsedHeaders(headers, rest)) =
    multipart.parse_headers(input, "frontier")

  headers
  |> should.equal([#("content-type", "text/plain")])
  rest
  |> should.equal(<<"This is the body of the message.\r\n--frontier\r\n":utf8>>)
}

pub fn parse_headers_2_test() {
  let input =
    bit_string.from_string(
      "--frontier\r
Content-Type: application/octet-stream\r
Content-Transfer-Encoding: base64\r
\r
PGh0bWw+CiAgPGhlYWQ+CiAgPC9oZWFkPgogIDxib2R5PgogICAgPHA+VGhpcyBpcyB0aGUg\r
Ym9keSBvZiB0aGUgbWVzc2FnZS48L3A+CiAgPC9ib2R5Pgo8L2h0bWw+Cg==\r
--frontier--",
    )

  let assert Ok(ParsedHeaders(headers, rest)) =
    multipart.parse_headers(input, "frontier")

  headers
  |> should.equal([
    #("content-type", "application/octet-stream"),
    #("content-transfer-encoding", "base64"),
  ])
  rest
  |> should.equal(<<
    "PGh0bWw+CiAgPGhlYWQ+CiAgPC9oZWFkPgogIDxib2R5PgogICAgPHA+VGhpcyBpcyB0aGUg\r\nYm9keSBvZiB0aGUgbWVzc2FnZS48L3A+CiAgPC9ib2R5Pgo8L2h0bWw+Cg==\r\n--frontier--":utf8,
  >>)
}
