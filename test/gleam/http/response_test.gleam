import gleam/http.{Http}
import gleam/http/cookie
import gleam/http/response.{Response}
import gleam/option.{None, Some}
import gleam/string
import gleeunit/should

pub fn redirect_test() {
  let response = response.redirect("/other")
  should.equal(303, response.status)
  should.equal(Ok("/other"), response.get_header(response, "location"))
}

pub fn map_body_test() {
  let response = Response(status: 200, headers: [], body: "abcd")
  let expected_updated_body = "dcba"
  let updated_response =
    response
    |> response.map(string.reverse)

  updated_response.body
  |> should.equal(expected_updated_body)
}

pub fn try_map_body_test() {
  let transform = fn(_old_body) { Ok("new body") }

  let response = response.new(200)
  response.try_map(response, transform)
  |> should.equal(Ok(Response(200, [], "new body")))

  // transform function which fails should propogate error
  let transform_failure = fn(_old_body) { Error("transform failure") }

  response.try_map(response, transform_failure)
  |> should.equal(Error("transform failure"))
}

pub fn get_header_test() {
  let response =
    response.new(200)
    |> response.prepend_header("x-foo", "x")
    |> response.prepend_header("x-BAR", "y")

  response.get_header(response, "x-foo")
  |> should.equal(Ok("x"))

  response.get_header(response, "X-Foo")
  |> should.equal(Ok("x"))

  response.get_header(response, "x-baz")
  |> should.equal(Error(Nil))

  response.headers
  |> should.equal([#("x-bar", "y"), #("x-foo", "x")])
}

pub fn set_header_test() {
  // sets header and replaces existing
  let response =
    response.new(200)
    |> response.set_header("x-one", "y")
    |> response.set_header("x-one", "x")
    |> response.set_header("x-two", "UPPERCASE")

  response.headers
  |> should.equal([#("x-one", "x"), #("x-two", "UPPERCASE")])
}

pub fn set_body_test() {
  let response =
    response.new(200)
    |> response.set_body("Hello, World!")

  response.body
  |> should.equal("Hello, World!")
}

pub fn get_resp_cookies_test() {
  let empty =
    cookie.Attributes(
      max_age: None,
      domain: None,
      path: None,
      secure: False,
      http_only: False,
      same_site: None,
    )

  response.new(200)
  |> response.set_cookie("k1", "v1", empty)
  |> response.get_cookies
  |> should.equal([#("k1", "v1")])

  let secure_with_attributes =
    cookie.Attributes(
      max_age: Some(100),
      domain: Some("domain.test"),
      path: Some("/foo"),
      secure: True,
      http_only: True,
      same_site: None,
    )

  response.new(200)
  |> response.set_cookie("k1", "v1", secure_with_attributes)
  |> response.get_cookies
  |> should.equal([
    #("k1", "v1"),
    #("Max-Age", "100"),
    #("Domain", "domain.test"),
    #("Path", "/foo"),
  ])

  // no response cookie
  response.new(200)
  |> response.prepend_header("k1", "v1")
  |> response.get_cookies
  |> should.equal([])
}

pub fn set_resp_cookie_test() {
  let empty =
    cookie.Attributes(
      max_age: None,
      domain: None,
      path: None,
      secure: False,
      http_only: False,
      same_site: None,
    )
  response.new(200)
  |> response.set_cookie("k1", "v1", empty)
  |> response.get_header("set-cookie")
  |> should.equal(Ok("k1=v1"))

  response.new(200)
  |> response.set_cookie("k1", "v1", cookie.defaults(Http))
  |> response.get_header("set-cookie")
  |> should.equal(Ok("k1=v1; Path=/; HttpOnly; SameSite=Lax"))

  let secure =
    cookie.Attributes(
      max_age: Some(100),
      domain: Some("domain.test"),
      path: Some("/foo"),
      secure: True,
      http_only: True,
      same_site: Some(cookie.Strict),
    )
  response.new(200)
  |> response.set_cookie("k1", "v1", secure)
  |> response.get_header("set-cookie")
  |> should.equal(Ok(
    "k1=v1; Max-Age=100; Domain=domain.test; Path=/foo; Secure; HttpOnly; SameSite=Strict",
  ))
}

pub fn expire_resp_cookie_test() {
  response.new(200)
  |> response.expire_cookie("k1", cookie.defaults(Http))
  |> response.get_header("set-cookie")
  |> should.equal(Ok(
    "k1=; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Max-Age=0; Path=/; HttpOnly; SameSite=Lax",
  ))
}
