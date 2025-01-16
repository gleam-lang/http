import gleam/dynamic.{DecodeError}
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
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "CONNECT"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "connect"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "Delete"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "DELETE"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "delete"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "Get"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "GET"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "get"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "Head"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "HEAD"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "head"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "Options"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "OPTIONS"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "options"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "Patch"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "PATCH"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "patch"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "Post"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "POST"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "post"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "Put"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "PUT"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "put"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "Trace"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "TRACE"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "trace"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "thingy"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "!#$%&'*+-.^_`|~abcABC123"
  |> make_atom
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "Atom", [])]))

  "In-valid method"
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
  |> should.equal(Ok(http.Other("Connect")))

  "CONNECT"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "connect"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("connect")))

  "Delete"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Delete")))

  "DELETE"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "delete"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("delete")))

  "Get"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Get")))

  "GET"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "get"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("get")))

  "Head"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Head")))

  "HEAD"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "head"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("head")))

  "Options"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Options")))

  "OPTIONS"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "options"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("options")))

  "Patch"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Patch")))

  "PATCH"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "patch"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("patch")))

  "Post"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Post")))

  "POST"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "post"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("post")))

  "Put"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Put")))

  "PUT"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "put"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("put")))

  "Trace"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Trace")))

  "TRACE"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "trace"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("trace")))

  "thingy"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("thingy")))

  "!#$%&'*+-.^_`|~abcABC123"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("!#$%&'*+-.^_`|~abcABC123")))

  "In-valid method"
  |> to_charlist
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "List", [])]))
}

pub fn method_from_dynamic_test() {
  "Connect"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Connect")))

  "CONNECT"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "connect"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("connect")))

  "Delete"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Delete")))

  "DELETE"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "delete"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("delete")))

  "Get"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Get")))

  "GET"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "get"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("get")))

  "Head"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Head")))

  "HEAD"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "head"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("head")))

  "Options"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Options")))

  "OPTIONS"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "options"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("options")))

  "Patch"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Patch")))

  "PATCH"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "patch"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("patch")))

  "Post"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Post")))

  "POST"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "post"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("post")))

  "Put"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Put")))

  "PUT"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "put"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("put")))

  "Trace"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("Trace")))

  "TRACE"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "trace"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("trace")))

  "thingy"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("thingy")))

  "!#$%&'*+-.^_`|~abcABC123"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Other("!#$%&'*+-.^_`|~abcABC123")))

  "In-valid method"
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Error([DecodeError("HTTP method", "String", [])]))
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
