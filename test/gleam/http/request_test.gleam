import gleam/http.{Https}
import gleam/http/request.{type Request, Request}
import gleam/option.{None, Some}
import gleam/string
import gleam/uri.{Uri}

pub fn req_to_uri_test() {
  let make_request = fn(scheme) -> Request(Nil) {
    Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme:,
      host: "sky.net",
      port: None,
      path: "/sarah/connor",
      query: None,
    )
  }

  assert http.Https
    |> make_request
    |> request.to_uri
    == Uri(
      Some("https"),
      None,
      Some("sky.net"),
      None,
      "/sarah/connor",
      None,
      None,
    )

  assert http.Http
    |> make_request
    |> request.to_uri
    == Uri(
      Some("http"),
      None,
      Some("sky.net"),
      None,
      "/sarah/connor",
      None,
      None,
    )
}

pub fn req_from_uri_test() {
  let uri =
    Uri(Some("https"), None, Some("sky.net"), None, "/sarah/connor", None, None)
  assert request.from_uri(uri)
    == Ok(Request(
      method: http.Get,
      headers: [],
      body: "",
      scheme: http.Https,
      host: "sky.net",
      port: None,
      path: "/sarah/connor",
      query: None,
    ))
}

pub fn req_from_url_test() {
  let url = "https://sky.net/sarah/connor?foo=x%20y"

  assert request.to(url)
    == Ok(Request(
      method: http.Get,
      headers: [],
      body: "",
      scheme: http.Https,
      host: "sky.net",
      port: None,
      path: "/sarah/connor",
      query: Some("foo=x%20y"),
    ))
}

pub fn path_segments_test() {
  let request =
    Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme: http.Https,
      host: "nostromo.ship",
      port: None,
      path: "/ellen/ripley",
      query: None,
    )

  assert ["ellen", "ripley"] == request.path_segments(request)
}

pub fn get_query_test() {
  let make_request = fn(query) {
    Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query:,
    )
  }

  let request = make_request(Some("foo=x%20y"))
  assert Ok([#("foo", "x y")]) == request.get_query(request)

  let request = make_request(None)
  assert Ok([]) == request.get_query(request)

  let request = make_request(Some("foo=%!2"))
  assert Error(Nil) == request.get_query(request)
}

pub fn set_query_test() {
  let request =
    Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: None,
    )

  let query = [#("answer", "42"), #("test", "123")]
  let updated_request = request.set_query(request, query)
  assert updated_request.query == Some("answer=42&test=123")

  let empty_query = []
  let updated_request = request.set_query(request, empty_query)
  assert updated_request.query == Some("")

  let query = [#("foo bar", "x y")]
  let updated_request = request.set_query(request, query)
  assert updated_request.query == Some("foo%20bar=x%20y")
}

pub fn get_req_header_test() {
  let make_request = fn(headers) {
    Request(
      method: http.Get,
      headers:,
      body: Nil,
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: None,
    )
  }

  let header_key = "GLEAM"
  let request = make_request([#("answer", "42"), #("gleam", "awesome")])
  assert request.get_header(request, header_key) == Ok("awesome")

  let request = make_request([#("answer", "42")])
  assert request.get_header(request, header_key) == Error(Nil)
}

pub fn set_req_body_test() {
  let body =
    "<html>
      <body>
        <title>Gleam is the best!</title>
      </body>
    </html>"

  let request =
    Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: None,
    )

  let updated_request =
    request
    |> request.set_body(body)

  assert updated_request.body == body
}

pub fn set_method_test() {
  let request =
    Request(
      method: http.Get,
      headers: [],
      body: "",
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: None,
    )

  let updated_request_method = http.Post
  let updated_request =
    request
    |> request.set_method(updated_request_method)

  assert updated_request.method == http.Post
}

pub fn map_req_body_test() {
  let request =
    request.new()
    |> request.set_body("abcd")

  let expected_updated_body = "dcba"
  let updated_request = request.map(request, string.reverse)

  assert updated_request.body == expected_updated_body
}

pub fn set_scheme_test() {
  let original_request = request.new()

  assert original_request.scheme == Https

  let updated_request =
    original_request
    |> request.set_scheme(http.Http)

  // scheme should be updated
  assert updated_request.scheme == http.Http
}

pub fn set_host_test() {
  let new_host = "github"
  let original_request = request.new()
  assert original_request.host == "localhost"

  let updated_request =
    original_request
    |> request.set_host(new_host)

  // host should be updated
  assert updated_request.host == new_host
}

pub fn set_port_test() {
  let original_request = request.new()

  assert original_request.port == None

  let updated_request =
    original_request
    |> request.set_port(4000)

  // port should be updated
  assert updated_request.port == Some(4000)
}

pub fn set_path_test() {
  let new_path = "/gleam-lang"
  let original_request = request.new()
  assert original_request.path == ""

  let updated_request =
    original_request
    |> request.set_path(new_path)

  // path should be updated
  assert updated_request.path == "/gleam-lang"
}

pub fn set_req_header_test() {
  let request =
    Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: None,
    )
    |> request.set_header("gleam", "awesome")

  assert request.headers == [#("gleam", "awesome")]

  // Set updates existing
  let request =
    request
    |> request.set_header("gleam", "quite good")

  assert request.headers == [#("gleam", "quite good")]
}

pub fn set_request_header_maintains_value_casing_test() {
  let request =
    Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: None,
    )
    |> request.set_header("gleam", "UPPERCASE_AWESOME")

  assert request.headers == [#("gleam", "UPPERCASE_AWESOME")]
}

pub fn set_request_header_lowercases_key_test() {
  let request =
    Request(
      method: http.Get,
      headers: [],
      body: Nil,
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: None,
    )
    |> request.set_header("UPPERCASE_GLEAM", "awesome")

  assert request.headers == [#("uppercase_gleam", "awesome")]
}

pub fn prepend_req_header_test() {
  let headers = []
  let request =
    Request(
      method: http.Get,
      headers:,
      body: Nil,
      scheme: http.Https,
      host: "example.com",
      port: None,
      path: "/",
      query: None,
    )
    |> request.prepend_header("answer", "42")

  assert request.headers == [#("answer", "42")]

  let request =
    request
    |> request.prepend_header("gleam", "awesome")

  // request should have two headers now
  assert request.headers == [#("gleam", "awesome"), #("answer", "42")]

  let request =
    request
    |> request.prepend_header("gleam", "awesome")

  // request repeats the existing header
  assert request.headers
    == [
      #("gleam", "awesome"),
      #("gleam", "awesome"),
      #("answer", "42"),
    ]
}

pub fn get_req_cookies_test() {
  assert request.new()
    |> request.prepend_header("cookie", "k1=v1; k2=v2")
    |> request.get_cookies()
    == [#("k1", "v1"), #("k2", "v2")]

  // Standard Header list syntax
  assert request.new()
    |> request.prepend_header("cookie", "k1=v1, k2=v2")
    |> request.get_cookies()
    == [#("k1", "v1"), #("k2", "v2")]

  // Spread over multiple headers
  assert request.new()
    |> request.prepend_header("cookie", "k2=v2")
    |> request.prepend_header("cookie", "k1=v1")
    |> request.get_cookies()
    == [#("k1", "v1"), #("k2", "v2")]

  assert request.new()
    |> request.prepend_header("cookie", " k1  =  v1 ; k2=v2 ")
    |> request.get_cookies()
    == [#("k1", "v1"), #("k2", "v2")]

  assert request.new()
    |> request.prepend_header("cookie", "k1; =; =123")
    |> request.get_cookies()
    == []

  assert request.new()
    |> request.prepend_header("cookie", "k\r1=v2; k1=v\r2")
    |> request.get_cookies()
    == []
}

pub fn set_req_cookies_test() {
  let request =
    request.new()
    |> request.set_cookie("k1", "v1")

  assert request.get_header(request, "cookie") == Ok("k1=v1")

  assert request
    |> request.set_cookie("k2", "v2")
    |> request.get_header("cookie")
    == Ok("k1=v1; k2=v2")
}

pub fn set_req_cookies_overwrite_test() {
  let request =
    request.new()
    |> request.set_cookie("k1", "k1")
    |> request.set_cookie("k2", "k2")
    |> request.set_cookie("k3", "k3")
    |> request.set_cookie("k4", "k4")
    |> request.set_cookie("k2", "k2-updated")
    |> request.set_cookie("k4", "k4-updated")

  assert request.get_header(request, "cookie")
    == Ok("k1=k1; k2=k2-updated; k3=k3; k4=k4-updated")
}

pub fn remove_cookie_from_request_test() {
  let req =
    request.new()
    |> request.set_cookie("FIRST_COOKIE", "first")
    |> request.set_cookie("SECOND_COOKIE", "second")
    |> request.set_cookie("THIRD_COOKIE", "third")

  let assert Ok(value) = request.get_header(req, "cookie")
  assert value == "FIRST_COOKIE=first; SECOND_COOKIE=second; THIRD_COOKIE=third"

  let modified_req =
    req
    |> request.remove_cookie("SECOND_COOKIE")

  let assert Ok(value) = request.get_header(modified_req, "cookie")
  assert value == "FIRST_COOKIE=first; THIRD_COOKIE=third"
}

pub fn only_remove_matching_cookies_test() {
  let assert Ok(value) =
    request.new()
    |> request.set_cookie("FIRST_COOKIE", "first")
    |> request.set_cookie("SECOND_COOKIE", "second")
    |> request.set_cookie("THIRD_COOKIE", "third")
    |> request.remove_cookie("SECOND")
    |> request.get_header("cookie")
  assert value == "FIRST_COOKIE=first; SECOND_COOKIE=second; THIRD_COOKIE=third"
}
