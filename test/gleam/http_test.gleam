import gleam/http
import gleeunit/should

pub fn parse_method_test() {
  "Connect"
  |> http.parse_method
  |> should.equal(Ok(http.Other("Connect")))

  "CONNECT"
  |> http.parse_method
  |> should.equal(Ok(http.Connect))

  "connect"
  |> http.parse_method
  |> should.equal(Ok(http.Other("connect")))

  "Delete"
  |> http.parse_method
  |> should.equal(Ok(http.Other("Delete")))

  "DELETE"
  |> http.parse_method
  |> should.equal(Ok(http.Delete))

  "delete"
  |> http.parse_method
  |> should.equal(Ok(http.Other("delete")))

  "Get"
  |> http.parse_method
  |> should.equal(Ok(http.Other("Get")))

  "GET"
  |> http.parse_method
  |> should.equal(Ok(http.Get))

  "get"
  |> http.parse_method
  |> should.equal(Ok(http.Other("get")))

  "Head"
  |> http.parse_method
  |> should.equal(Ok(http.Other("Head")))

  "HEAD"
  |> http.parse_method
  |> should.equal(Ok(http.Head))

  "head"
  |> http.parse_method
  |> should.equal(Ok(http.Other("head")))

  "Options"
  |> http.parse_method
  |> should.equal(Ok(http.Other("Options")))

  "OPTIONS"
  |> http.parse_method
  |> should.equal(Ok(http.Options))

  "options"
  |> http.parse_method
  |> should.equal(Ok(http.Other("options")))

  "Patch"
  |> http.parse_method
  |> should.equal(Ok(http.Other("Patch")))

  "PATCH"
  |> http.parse_method
  |> should.equal(Ok(http.Patch))

  "patch"
  |> http.parse_method
  |> should.equal(Ok(http.Other("patch")))

  "Post"
  |> http.parse_method
  |> should.equal(Ok(http.Other("Post")))

  "POST"
  |> http.parse_method
  |> should.equal(Ok(http.Post))

  "post"
  |> http.parse_method
  |> should.equal(Ok(http.Other("post")))

  "Put"
  |> http.parse_method
  |> should.equal(Ok(http.Other("Put")))

  "PUT"
  |> http.parse_method
  |> should.equal(Ok(http.Put))

  "put"
  |> http.parse_method
  |> should.equal(Ok(http.Other("put")))

  "Trace"
  |> http.parse_method
  |> should.equal(Ok(http.Other("Trace")))

  "TRACE"
  |> http.parse_method
  |> should.equal(Ok(http.Trace))

  "trace"
  |> http.parse_method
  |> should.equal(Ok(http.Other("trace")))

  "thingy"
  |> http.parse_method
  |> should.equal(Ok(http.Other("thingy")))

  "!#$%&'*+-.^_`|~abcABC123"
  |> http.parse_method
  |> should.equal(Ok(http.Other("!#$%&'*+-.^_`|~abcABC123")))

  "In-valid method"
  |> http.parse_method
  |> should.equal(Error(Nil))
}

pub fn method_to_string_test() {
  http.Connect
  |> http.method_to_string
  |> should.equal("CONNECT")

  http.Delete
  |> http.method_to_string
  |> should.equal("DELETE")

  http.Get
  |> http.method_to_string
  |> should.equal("GET")

  http.Head
  |> http.method_to_string
  |> should.equal("HEAD")

  http.Options
  |> http.method_to_string
  |> should.equal("OPTIONS")

  http.Patch
  |> http.method_to_string
  |> should.equal("PATCH")

  http.Post
  |> http.method_to_string
  |> should.equal("POST")

  http.Put
  |> http.method_to_string
  |> should.equal("PUT")

  http.Trace
  |> http.method_to_string
  |> should.equal("TRACE")

  http.Other("ok")
  |> http.method_to_string
  |> should.equal("ok")

  http.Other("nope")
  |> http.method_to_string
  |> should.equal("nope")
}

pub fn scheme_to_string_test() {
  http.Http
  |> http.scheme_to_string
  |> should.equal("http")

  http.Https
  |> http.scheme_to_string
  |> should.equal("https")
}

pub fn scheme_from_string_test() {
  "http"
  |> http.scheme_from_string
  |> should.equal(Ok(http.Http))

  "https"
  |> http.scheme_from_string
  |> should.equal(Ok(http.Https))

  "ftp"
  |> http.scheme_from_string
  |> should.equal(Error(Nil))
}

pub fn parse_content_disposition_1_test() {
  http.parse_content_disposition("inline")
  |> should.equal(Ok(http.ContentDisposition("inline", [])))

  http.parse_content_disposition("attachment")
  |> should.equal(Ok(http.ContentDisposition("attachment", [])))

  http.parse_content_disposition(
    "attachment; filename=genome.jpeg; modification-date=\"Wed, 12 Feb 1997 16:29:51 -0500\";",
  )
  |> should.equal(
    Ok(
      http.ContentDisposition("attachment", [
        #("filename", "genome.jpeg"),
        #("modification-date", "Wed, 12 Feb 1997 16:29:51 -0500"),
      ]),
    ),
  )

  http.parse_content_disposition("form-data; name=\"user\"")
  |> should.equal(Ok(http.ContentDisposition("form-data", [#("name", "user")])))

  http.parse_content_disposition("form-data; NAME=\"submit-name\"")
  |> should.equal(
    Ok(http.ContentDisposition("form-data", [#("name", "submit-name")])),
  )

  http.parse_content_disposition(
    "form-data; name=\"files\"; filename=\"file1.txt\"",
  )
  |> should.equal(
    Ok(
      http.ContentDisposition("form-data", [
        #("name", "files"),
        #("filename", "file1.txt"),
      ]),
    ),
  )

  http.parse_content_disposition("file; filename=\"file1.txt\"")
  |> should.equal(
    Ok(http.ContentDisposition("file", [#("filename", "file1.txt")])),
  )

  http.parse_content_disposition("file; filename=\"file2.gif\"")
  |> should.equal(
    Ok(http.ContentDisposition("file", [#("filename", "file2.gif")])),
  )

  http.parse_content_disposition("file; filename=\"file2\\\".gif\"")
  |> should.equal(
    Ok(http.ContentDisposition("file", [#("filename", "file2\".gif")])),
  )

  http.parse_content_disposition("file; filename=\"file2")
  |> should.equal(Error(Nil))
}
