import gleeunit/should
import gleam/bit_string
import gleam/list
import gleam/http.{
  MoreRequiredForBody, MoreRequiredForHeaders, MultipartBody, MultipartHeaders,
}

pub fn parse_multipart_headers_1_test() {
  let input = <<
    "This is the preamble. It is to be ignored, though it\r
is a handy place for composition agents to include an\r
explanatory note to non-MIME conformant readers.\r
\r
--frontier\r
Content-Type: text/plain\r
\r
This is the body of the message.\r
--frontier\r
":utf8,
  >>

  let assert Ok(MultipartHeaders(headers, rest)) =
    http.parse_multipart_headers(input, "frontier")

  headers
  |> should.equal([#("content-type", "text/plain")])
  rest
  |> should.equal(<<"This is the body of the message.\r\n--frontier\r\n":utf8>>)
}

pub fn parse_multipart_headers_2_test() {
  let input = <<
    "--wibblewobble\r
Content-Type: application/octet-stream\r
Content-Transfer-Encoding: base64\r
\r
PGh0bWw+CiAgPGhlYWQ+CiAgPC9oZWFkPgogIDxib2R5PgogICAgPHA+VGhpcyBpcyB0aGUg\r
Ym9keSBvZiB0aGUgbWVzc2FnZS48L3A+CiAgPC9ib2R5Pgo8L2h0bWw+Cg==\r
--wibblewobble--":utf8,
  >>

  let assert Ok(MultipartHeaders(headers, rest)) =
    http.parse_multipart_headers(input, "wibblewobble")

  headers
  |> should.equal([
    #("content-type", "application/octet-stream"),
    #("content-transfer-encoding", "base64"),
  ])
  rest
  |> should.equal(<<
    "PGh0bWw+CiAgPGhlYWQ+CiAgPC9oZWFkPgogIDxib2R5PgogICAgPHA+VGhpcyBpcyB0aGUg\r
Ym9keSBvZiB0aGUgbWVzc2FnZS48L3A+CiAgPC9ib2R5Pgo8L2h0bWw+Cg==\r\n--wibblewobble--":utf8,
  >>)
}

/// This test uses the `slices` function to split the input into every possible
/// pair of bit-strings and then parses the headers from each pair.
/// This ensures that no matter where the input gets chunked the parser will
/// return the same result.
pub fn parse_multipart_headers_chunked_test() {
  let input = <<
    "This is the preamble. It is to be ignored, though it\r
is a handy place for composition agents to include an\r
explanatory note to non-MIME conformant readers.\r
\r
--frontier\r
Content-Type: text/plain\r
\r
This is the body of the message.\r
--frontier\r
":utf8,
  >>
  use #(before, after) <- list.each(slices(<<>>, input, []))

  let assert Ok(return) = http.parse_multipart_headers(before, "frontier")

  let assert Ok(MultipartHeaders(headers, rest)) = case return {
    MoreRequiredForHeaders(continue) -> continue(after)
    MultipartHeaders(headers, remaining) ->
      Ok(MultipartHeaders(headers, bit_string.append(remaining, after)))
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

/// This test uses the `slices` function to split the input into every possible
/// pair of bit-strings and then parses the headers from each pair.
/// This ensures that no matter where the input gets chunked the parser will
/// return the same result.
pub fn parse_multipart_body_chunked_test() {
  let input = <<
    "This is the body of the message.\r
--frontier\r
Content-Type: text/plain\r
This is the body of the next part\r
--frontier\r
":utf8,
  >>
  use #(before, after) <- list.each(slices(<<>>, input, []))

  let assert Ok(return) = http.parse_multipart_body(before, "frontier")

  let assert Ok(MultipartBody(body, False, rest)) = case return {
    MoreRequiredForBody(chunk, continue) -> {
      let assert Ok(MultipartBody(body, done, remaining)) = continue(after)
      Ok(MultipartBody(bit_string.append(chunk, body), done, remaining))
    }
    MultipartBody(body, done, remaining) ->
      Ok(MultipartBody(body, done, bit_string.append(remaining, after)))
  }

  body
  |> should.equal(<<"This is the body of the message.":utf8>>)
  rest
  |> should.equal(<<
    "--frontier\r
Content-Type: text/plain\r
This is the body of the next part\r
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

pub fn parse_1_test() {
  let input = <<
    "This is a message with multiple parts in MIME format.\r
--frontier\r
Content-Type: text/plain\r
\r
This is the body of the message.\r
--frontier\r
Content-Type: application/octet-stream\r
Content-Transfer-Encoding: base64\r
\r
PGh0bWw+CiAgPGhlYWQ+CiAgPC9oZWFkPgogIDxib2R5PgogICAgPHA+VGhpcyBpcyB0aGUg\r
Ym9keSBvZiB0aGUgbWVzc2FnZS48L3A+CiAgPC9ib2R5Pgo8L2h0bWw+Cg==\r
--frontier--":utf8,
  >>

  let assert Ok(MultipartBody(body, False, input)) =
    http.parse_multipart_body(input, "frontier")
  body
  |> should.equal(<<
    "This is a message with multiple parts in MIME format.":utf8,
  >>)

  let assert Ok(MultipartHeaders(headers, input)) =
    http.parse_multipart_headers(input, "frontier")
  headers
  |> should.equal([#("content-type", "text/plain")])

  let assert Ok(MultipartBody(body, False, input)) =
    http.parse_multipart_body(input, "frontier")
  body
  |> should.equal(<<"This is the body of the message.":utf8>>)

  let assert Ok(MultipartHeaders(headers, input)) =
    http.parse_multipart_headers(input, "frontier")
  headers
  |> should.equal([
    #("content-type", "application/octet-stream"),
    #("content-transfer-encoding", "base64"),
  ])

  let assert Ok(MultipartBody(body, True, rest)) =
    http.parse_multipart_body(input, "frontier")
  body
  |> should.equal(<<
    "PGh0bWw+CiAgPGhlYWQ+CiAgPC9oZWFkPgogIDxib2R5PgogICAgPHA+VGhpcyBpcyB0aGUg\r
Ym9keSBvZiB0aGUgbWVzc2FnZS48L3A+CiAgPC9ib2R5Pgo8L2h0bWw+Cg==":utf8,
  >>)
  rest
  |> should.equal(<<>>)
}

pub fn parse_2_test() {
  let input = <<
    "--AaB03x\r
Content-Disposition: form-data; name=\"submit-name\"\r
\r
Larry\r
--AaB03x\r
Content-Disposition: form-data; name=\"files\"\r
Content-Type: multipart/mixed; boundary=BbC04y\r
\r
--BbC04y\r
Content-Disposition: file; filename=\"file1.txt\"\r
Content-Type: text/plain\r
\r
... contents of file1.txt ...\r
--BbC04y\r
Content-Disposition: file; filename=\"file2.gif\"\r
Content-Type: image/gif\r
Content-Transfer-Encoding: binary\r
\r
...contents of file2.gif...\r
--BbC04y--\r
--AaB03x--":utf8,
  >>

  let assert Ok(MultipartHeaders(headers, input)) =
    http.parse_multipart_headers(input, "AaB03x")
  headers
  |> should.equal([#("content-disposition", "form-data; name=\"submit-name\"")])

  let assert Ok(MultipartBody(body, False, input)) =
    http.parse_multipart_body(input, "AaB03x")
  body
  |> should.equal(<<"Larry":utf8>>)

  let assert Ok(MultipartHeaders(headers, input)) =
    http.parse_multipart_headers(input, "AaB03x")
  headers
  |> should.equal([
    #("content-disposition", "form-data; name=\"files\""),
    // The boundary is changed here!
    #("content-type", "multipart/mixed; boundary=BbC04y"),
  ])

  let assert Ok(MultipartBody(body, False, input)) =
    http.parse_multipart_body(input, "BbC04y")
  body
  |> should.equal(<<"":utf8>>)

  let assert Ok(MultipartHeaders(headers, input)) =
    http.parse_multipart_headers(input, "BbC04y")
  headers
  |> should.equal([
    #("content-disposition", "file; filename=\"file1.txt\""),
    #("content-type", "text/plain"),
  ])

  let assert Ok(MultipartBody(body, False, input)) =
    http.parse_multipart_body(input, "BbC04y")
  body
  |> should.equal(<<"... contents of file1.txt ...":utf8>>)

  let assert Ok(MultipartHeaders(headers, input)) =
    http.parse_multipart_headers(input, "BbC04y")
  headers
  |> should.equal([
    #("content-disposition", "file; filename=\"file2.gif\""),
    #("content-type", "image/gif"),
    #("content-transfer-encoding", "binary"),
  ])

  let assert Ok(MultipartBody(body, True, input)) =
    http.parse_multipart_body(input, "BbC04y")
  body
  |> should.equal(<<"...contents of file2.gif...":utf8>>)

  let assert Ok(MultipartBody(body, True, input)) =
    http.parse_multipart_body(input, "AaB03x")
  body
  |> should.equal(<<>>)
  input
  |> should.equal(<<>>)
}

pub fn parse_3_test() {
  let input = <<
    "This is the preamble.\r
--boundary\r
Content-Type: text/plain\r
\r
This is the body of the message.\r
--boundary--\r
This is the epilogue. Here it includes leading CRLF":utf8,
  >>

  let assert Ok(MultipartBody(body, False, input)) =
    http.parse_multipart_body(input, "boundary")
  body
  |> should.equal(<<"This is the preamble.":utf8>>)

  let assert Ok(MultipartHeaders(headers, input)) =
    http.parse_multipart_headers(input, "boundary")
  headers
  |> should.equal([#("content-type", "text/plain")])

  let assert Ok(MultipartBody(body, True, input)) =
    http.parse_multipart_body(input, "boundary")
  body
  |> should.equal(<<"This is the body of the message.":utf8>>)

  input
  |> should.equal(<<
    "\r\nThis is the epilogue. Here it includes leading CRLF":utf8,
  >>)
}

pub fn parse_4_test() {
  let input = <<
    "This is the preamble.\r
--boundary\r
Content-Type: text/plain\r
\r
This is the body of the message.\r
--boundary--\r
":utf8,
  >>

  let assert Ok(MultipartBody(body, False, input)) =
    http.parse_multipart_body(input, "boundary")
  body
  |> should.equal(<<"This is the preamble.":utf8>>)

  let assert Ok(MultipartHeaders(headers, input)) =
    http.parse_multipart_headers(input, "boundary")
  headers
  |> should.equal([#("content-type", "text/plain")])

  let assert Ok(MultipartBody(body, True, input)) =
    http.parse_multipart_body(input, "boundary")
  body
  |> should.equal(<<"This is the body of the message.":utf8>>)

  input
  |> should.equal(<<"\r\n":utf8>>)
}

pub fn parse_5_test() {
  let input = <<
    "This is the preamble.  It is to be ignored, though it\r
is a handy place for composition agents to include an\r
explanatory note to non-MIME conformant readers.\r
\r
--simple boundary\r
\r
This is implicitly typed plain US-ASCII text.\r
It does NOT end with a linebreak.\r
--simple boundary\r
Content-type: text/plain; charset=us-ascii\r
\r
This is explicitly typed plain US-ASCII text.\r
It DOES end with a linebreak.\r
\r
--simple boundary--\r
\r
This is the epilogue.  It is also to be ignored.":utf8,
  >>

  let assert Ok(MultipartBody(body, False, input)) =
    http.parse_multipart_body(input, "simple boundary")
  body
  |> should.equal(<<
    "This is the preamble.  It is to be ignored, though it\r
is a handy place for composition agents to include an\r
explanatory note to non-MIME conformant readers.\r
":utf8,
  >>)

  let assert Ok(MultipartHeaders(headers, input)) =
    http.parse_multipart_headers(input, "simple boundary")
  headers
  |> should.equal([])

  let assert Ok(MultipartBody(body, False, input)) =
    http.parse_multipart_body(input, "simple boundary")
  body
  |> should.equal(<<
    "This is implicitly typed plain US-ASCII text.\r
It does NOT end with a linebreak.":utf8,
  >>)

  let assert Ok(MultipartHeaders(headers, input)) =
    http.parse_multipart_headers(input, "simple boundary")
  headers
  |> should.equal([#("content-type", "text/plain; charset=us-ascii")])

  let assert Ok(MultipartBody(body, True, input)) =
    http.parse_multipart_body(input, "simple boundary")
  body
  |> should.equal(<<
    "This is explicitly typed plain US-ASCII text.\r
It DOES end with a linebreak.\r
":utf8,
  >>)

  input
  |> should.equal(<<
    "\r\n\r\nThis is the epilogue.  It is also to be ignored.":utf8,
  >>)
}
