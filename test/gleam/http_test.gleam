import gleam/atom
import gleam/dynamic
import gleam/string_builder
import gleam/uri.{Uri}
import gleam/http
import gleam/http/cookie
import gleam/option.{None, Some}
import gleam/should

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

external fn to_charlist(String) -> List(Int) =
  "unicode" "characters_to_list"

pub fn method_from_dynamic_test() {
  "Connect"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "CONNECT"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "connect"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Connect))

  "Delete"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "DELETE"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "delete"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Delete))

  "Get"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "GET"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "get"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Get))

  "Head"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "HEAD"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "head"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Head))

  "Options"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "OPTIONS"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "options"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Options))

  "Patch"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "PATCH"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "patch"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Patch))

  "Post"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "POST"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "post"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Post))

  "Put"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "PUT"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "put"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Put))

  "Trace"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "TRACE"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "trace"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Ok(http.Trace))

  "thingy"
  |> atom.create_from_string
  |> dynamic.from
  |> http.method_from_dynamic
  |> should.equal(Error(Nil))

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
  |> should.equal(Error(Nil))

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
  |> should.equal(Error(Nil))
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

pub fn req_to_uri_test() {
  let make_request = fn(scheme) -> http.Request(Nil) {
    http.Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme: scheme,
      host: "sky.net",
      port: None,
      path: "/sarah/connor",
      query: None,
    )
  }

  http.Https
  |> make_request
  |> http.req_to_uri
  |> should.equal(
    Uri(Some("https"), None, Some("sky.net"), None, "/sarah/connor", None, None),
  )

  http.Http
  |> make_request
  |> http.req_to_uri
  |> should.equal(
    Uri(Some("http"), None, Some("sky.net"), None, "/sarah/connor", None, None),
  )
}

pub fn redirect_test() {
  let response = http.redirect("/other")

  should.equal(303, response.status)
  should.equal(Ok("/other"), http.get_resp_header(response, "location"))
}

pub fn path_segments_test() {
  let request = http.Request(
    method: http.Get,
    headers: [],
    body: Nil,
    scheme: http.Https,
    host: "nostromo.ship",
    port: None,
    path: "/ellen/ripley",
    query: None,
  )

  should.equal(["ellen", "ripley"], http.path_segments(request))
}

pub fn get_query_test() {
  let make_request = fn(query) {
    http.Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: query,
    )
  }

  let request = make_request(Some("foo=x%20y"))
  should.equal(Ok([tuple("foo", "x y")]), http.get_query(request))

  let request = make_request(None)
  should.equal(Ok([]), http.get_query(request))

  let request = make_request(Some("foo=%!2"))
  should.equal(Error(Nil), http.get_query(request))
}

pub fn get_resp_header_test() {
  let response = http.response(200)
    |> http.prepend_resp_header("x-foo", "x")
    |> http.prepend_resp_header("x-BAR", "y")

  http.get_resp_header(response, "x-foo")
  |> should.equal(Ok("x"))

  http.get_resp_header(response, "X-Foo")
  |> should.equal(Ok("x"))

  http.get_resp_header(response, "x-baz")
  |> should.equal(Error(Nil))

  response.headers
  |> should.equal([tuple("x-bar", "y"), tuple("x-foo", "x")])
}

pub fn resp_body_test() {
  let response = http.response(200)
    |> http.set_resp_body("Hello, World!")

  response.body
  |> should.equal("Hello, World!")
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

pub fn get_req_cookies_test() {
  http.default_req()
  |> http.prepend_req_header("cookie", "k1=v1; k2=v2")
  |> http.get_req_cookies()
  |> should.equal([tuple("k1", "v1"), tuple("k2", "v2")])

  // Standard Header list syntax
  http.default_req()
  |> http.prepend_req_header("cookie", "k1=v1, k2=v2")
  |> http.get_req_cookies()
  |> should.equal([tuple("k1", "v1"), tuple("k2", "v2")])

  // Spread over multiple headers
  http.default_req()
  |> http.prepend_req_header("cookie", "k2=v2")
  |> http.prepend_req_header("cookie", "k1=v1")
  |> http.get_req_cookies()
  |> should.equal([tuple("k1", "v1"), tuple("k2", "v2")])

  http.default_req()
  |> http.prepend_req_header("cookie", " k1=v1 ; k2=v2 ")
  |> http.get_req_cookies()
  |> should.equal([tuple("k1", "v1"), tuple("k2", "v2")])

  http.default_req()
  |> http.prepend_req_header("cookie", "k1; =; =123")
  |> http.get_req_cookies()
  |> should.equal([])

  http.default_req()
  |> http.prepend_req_header("cookie", "k\r1=v2; k1=v\r2")
  |> http.get_req_cookies()
  |> should.equal([])
}

pub fn set_req_cookies_test() {
  let request = http.default_req()
    |> http.set_req_cookie("k1", "v1")

  request
  |> http.get_req_header("cookie")
  |> should.equal(Ok("k1=v1"))

  request
  |> http.set_req_cookie("k2", "v2")
  |> http.get_req_header("cookie")
  |> should.equal(Ok("k1=v1; k2=v2"))
}

pub fn set_resp_cookie_test() {
  http.response(200)
  |> http.set_resp_cookie("k1", "v1", cookie.empty_attributes())
  |> http.get_resp_header("set-cookie")
  |> should.equal(Ok("k1=v1"))

  http.response(200)
  |> http.set_resp_cookie("k1", "v1", cookie.default_attributes())
  |> http.get_resp_header("set-cookie")
  |> should.equal(Ok("k1=v1; Path=/; HttpOnly"))

  http.response(200)
  |> http.set_resp_cookie(
    "k1",
    "v1",
    cookie.Attributes(
      max_age: Some(100),
      domain: Some("domain.test"),
      path: Some("/foo"),
      secure: True,
      http_only: True,
      same_site: Some(cookie.Strict),
    ),
  )
  |> http.get_resp_header("set-cookie")
  |> should.equal(
    Ok(
      "k1=v1; MaxAge=100; Domain=domain.test; Path=/foo; Secure; HttpOnly; SameSite=Strict",
    ),
  )
}

pub fn expire_resp_cookie_test() {
    http.response(200)
    |> http.expire_resp_cookie("k1" , cookie.default_attributes())
    |> http.get_resp_header("set-cookie")
    |> should.equal(Ok("k1=; expires=Thu, 01 Jan 1970 00:00:00 GMT; MaxAge=0; Path=/; HttpOnly"))
}
