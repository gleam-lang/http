import gleam/http.{Http}
import gleam/http/cookie
import gleam/http/response.{Response}
import gleam/option.{None, Some}
import gleam/string

pub fn redirect_test() {
  let response = response.redirect("/other")
  assert 303 == response.status
  assert Ok("/other") == response.get_header(response, "location")
}

pub fn map_body_test() {
  let response = Response(status: 200, headers: [], body: "abcd")
  let expected_updated_body = "dcba"
  let updated_response =
    response
    |> response.map(string.reverse)

  assert updated_response.body == expected_updated_body
}

pub fn try_map_body_test() {
  let transform = fn(_old_body) { Ok("new body") }

  let response = response.new(200)
  assert response.try_map(response, transform)
    == Ok(Response(200, [], "new body"))

  // transform function which fails should propogate error
  let transform_failure = fn(_old_body) { Error("transform failure") }

  assert response.try_map(response, transform_failure)
    == Error("transform failure")
}

pub fn get_header_test() {
  let response =
    response.new(200)
    |> response.prepend_header("x-foo", "x")
    |> response.prepend_header("x-BAR", "y")

  assert response.get_header(response, "x-foo") == Ok("x")

  assert response.get_header(response, "X-Foo") == Ok("x")

  assert response.get_header(response, "x-baz") == Error(Nil)

  assert response.headers == [#("x-bar", "y"), #("x-foo", "x")]
}

pub fn set_header_test() {
  // sets header and replaces existing
  let response =
    response.new(200)
    |> response.set_header("x-one", "y")
    |> response.set_header("x-one", "x")
    |> response.set_header("x-two", "UPPERCASE")

  assert response.headers == [#("x-one", "x"), #("x-two", "UPPERCASE")]
}

pub fn set_body_test() {
  let response =
    response.new(200)
    |> response.set_body("Hello, World!")

  assert response.body == "Hello, World!"
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

  assert response.new(200)
    |> response.set_cookie("k1", "v1", empty)
    |> response.get_cookies
    == [#("k1", "v1")]

  let secure_with_attributes =
    cookie.Attributes(
      max_age: Some(100),
      domain: Some("domain.test"),
      path: Some("/foo"),
      secure: True,
      http_only: True,
      same_site: None,
    )

  assert response.new(200)
    |> response.set_cookie("k1", "v1", secure_with_attributes)
    |> response.get_cookies
    == [
      #("k1", "v1"),
      #("Max-Age", "100"),
      #("Domain", "domain.test"),
      #("Path", "/foo"),
    ]

  // no response cookie
  assert response.new(200)
    |> response.prepend_header("k1", "v1")
    |> response.get_cookies
    == []
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
  assert response.new(200)
    |> response.set_cookie("k1", "v1", empty)
    |> response.get_header("set-cookie")
    == Ok("k1=v1")

  assert response.new(200)
    |> response.set_cookie("k1", "v1", cookie.defaults(Http))
    |> response.get_header("set-cookie")
    == Ok("k1=v1; Path=/; HttpOnly; SameSite=Lax")

  let secure =
    cookie.Attributes(
      max_age: Some(100),
      domain: Some("domain.test"),
      path: Some("/foo"),
      secure: True,
      http_only: True,
      same_site: Some(cookie.Strict),
    )
  assert response.new(200)
    |> response.set_cookie("k1", "v1", secure)
    |> response.get_header("set-cookie")
    == Ok(
      "k1=v1; Max-Age=100; Domain=domain.test; Path=/foo; Secure; HttpOnly; SameSite=Strict",
    )
}

pub fn expire_resp_cookie_test() {
  assert response.new(200)
    |> response.expire_cookie("k1", cookie.defaults(Http))
    |> response.get_header("set-cookie")
    == Ok(
      "k1=; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Max-Age=0; Path=/; HttpOnly; SameSite=Lax",
    )
}
