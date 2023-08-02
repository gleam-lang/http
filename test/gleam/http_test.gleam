import gleam/dynamic.{DecodeError}
import gleam/http
import gleeunit/should

pub fn parse_method_test() {
  "Connect"
  |> http.parse_method
  |> should.equal(Ok(http.Connect))

  "CONNECT"
  |> http.parse_method
  |> should.equal(Ok(http.Connect))

  "connect"
  |> http.parse_method
  |> should.equal(Ok(http.Connect))

  "Delete"
  |> http.parse_method
  |> should.equal(Ok(http.Delete))

  "DELETE"
  |> http.parse_method
  |> should.equal(Ok(http.Delete))

  "delete"
  |> http.parse_method
  |> should.equal(Ok(http.Delete))

  "Get"
  |> http.parse_method
  |> should.equal(Ok(http.Get))

  "GET"
  |> http.parse_method
  |> should.equal(Ok(http.Get))

  "get"
  |> http.parse_method
  |> should.equal(Ok(http.Get))

  "Head"
  |> http.parse_method
  |> should.equal(Ok(http.Head))

  "HEAD"
  |> http.parse_method
  |> should.equal(Ok(http.Head))

  "head"
  |> http.parse_method
  |> should.equal(Ok(http.Head))

  "Options"
  |> http.parse_method
  |> should.equal(Ok(http.Options))

  "OPTIONS"
  |> http.parse_method
  |> should.equal(Ok(http.Options))

  "options"
  |> http.parse_method
  |> should.equal(Ok(http.Options))

  "Patch"
  |> http.parse_method
  |> should.equal(Ok(http.Patch))

  "PATCH"
  |> http.parse_method
  |> should.equal(Ok(http.Patch))

  "patch"
  |> http.parse_method
  |> should.equal(Ok(http.Patch))

  "Post"
  |> http.parse_method
  |> should.equal(Ok(http.Post))

  "POST"
  |> http.parse_method
  |> should.equal(Ok(http.Post))

  "post"
  |> http.parse_method
  |> should.equal(Ok(http.Post))

  "Put"
  |> http.parse_method
  |> should.equal(Ok(http.Put))

  "PUT"
  |> http.parse_method
  |> should.equal(Ok(http.Put))

  "put"
  |> http.parse_method
  |> should.equal(Ok(http.Put))

  "Trace"
  |> http.parse_method
  |> should.equal(Ok(http.Trace))

  "TRACE"
  |> http.parse_method
  |> should.equal(Ok(http.Trace))

  "trace"
  |> http.parse_method
  |> should.equal(Ok(http.Trace))

  "thingy"
  |> http.parse_method
  |> should.equal(Error(Nil))
}

@target(erlang)
@external(erlang, "unicode", "characters_to_list")
fn to_charlist(a: String) -> List(Int)

@target(erlang)
@external(erlang, "gleam_http_test_helper", "atom")
fn make_atom(a: String) -> dynamic.Dynamic

@target(erlang)
pub fn method_from_dynamic_atom_test() {
  "Connect"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "CONNECT"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "connect"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "Delete"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "DELETE"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "delete"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "Get"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "GET"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "get"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "Head"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "HEAD"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "head"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "Options"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "OPTIONS"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "options"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "Patch"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "PATCH"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "patch"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "Post"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "POST"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "post"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "Put"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "PUT"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "put"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "Trace"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "TRACE"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "trace"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "thingy"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))
}

@target(erlang)
pub fn charlist_to_method_test() {
  "Connect"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "CONNECT"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "connect"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "Delete"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "DELETE"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "delete"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "Get"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "GET"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "get"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "Head"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "HEAD"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "head"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "Options"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "OPTIONS"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "options"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "Patch"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "PATCH"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "patch"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "Post"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "POST"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "post"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "Put"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "PUT"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "put"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "Trace"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "TRACE"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "trace"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "thingy"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "List", [])]))
}

pub fn method_from_dynamic_test() {
  "Connect"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "CONNECT"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "connect"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "Delete"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "DELETE"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "delete"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "Get"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "GET"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "get"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "Head"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "HEAD"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "head"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "Options"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "OPTIONS"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "options"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "Patch"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "PATCH"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "patch"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "Post"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "POST"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "post"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "Put"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "PUT"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "put"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "Trace"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "TRACE"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "trace"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "thingy"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "String", [])]))
}

pub fn method_to_string_test() {
  http.Connect
  |> http.method_to_string
  |> should.equal("connect")

  http.Delete
  |> http.method_to_string
  |> should.equal("delete")

  http.Get
  |> http.method_to_string
  |> should.equal("get")

  http.Head
  |> http.method_to_string
  |> should.equal("head")

  http.Options
  |> http.method_to_string
  |> should.equal("options")

  http.Patch
  |> http.method_to_string
  |> should.equal("patch")

  http.Post
  |> http.method_to_string
  |> should.equal("post")

  http.Put
  |> http.method_to_string
  |> should.equal("put")

  http.Trace
  |> http.method_to_string
  |> should.equal("trace")

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
  |> should.equal(Ok(http.ContentDisposition(
    "attachment",
    [
      #("filename", "genome.jpeg"),
      #("modification-date", "Wed, 12 Feb 1997 16:29:51 -0500"),
    ],
  )))

  http.parse_content_disposition("form-data; name=\"user\"")
  |> should.equal(Ok(http.ContentDisposition("form-data", [#("name", "user")])))

  http.parse_content_disposition("form-data; NAME=\"submit-name\"")
  |> should.equal(Ok(http.ContentDisposition(
    "form-data",
    [#("name", "submit-name")],
  )))

  http.parse_content_disposition(
    "form-data; name=\"files\"; filename=\"file1.txt\"",
  )
  |> should.equal(Ok(http.ContentDisposition(
    "form-data",
    [#("name", "files"), #("filename", "file1.txt")],
  )))

  http.parse_content_disposition("file; filename=\"file1.txt\"")
  |> should.equal(Ok(http.ContentDisposition(
    "file",
    [#("filename", "file1.txt")],
  )))

  http.parse_content_disposition("file; filename=\"file2.gif\"")
  |> should.equal(Ok(http.ContentDisposition(
    "file",
    [#("filename", "file2.gif")],
  )))

  http.parse_content_disposition("file; filename=\"file2\\\".gif\"")
  |> should.equal(Ok(http.ContentDisposition(
    "file",
    [#("filename", "file2\".gif")],
  )))

  http.parse_content_disposition("file; filename=\"file2")
  |> should.equal(Error(Nil))
}
