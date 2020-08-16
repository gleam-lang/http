import gleam/http.{Delete, Patch, Post, Put, Request, Service}
import gleam/list
import gleam/result

pub type Middleware(before_req, before_resp, after_req, after_resp) =
  fn(Service(before_req, before_resp)) -> Service(after_req, after_resp)

/// A middleware that transform the response body returned by the service using
/// a given function.
///
pub fn map_resp_body(
  service: Service(req, a),
  with mapper: fn(a) -> b,
) -> Service(req, b) {
  fn(req) {
    req
    |> service
    |> http.map_resp_body(mapper)
  }
}

/// A middleware that prepends a header to the request.
///
pub fn prepend_resp_header(
  service: Service(req, resp),
  key: String,
  value: String,
) -> Service(req, resp) {
  fn(req) {
    req
    |> service
    |> http.prepend_resp_header(key, value)
  }
}

fn ensure_post(req: Request(a)) {
  case req.method {
    Post -> Ok(req)
    _ -> Error(Nil)
  }
}

fn get_override_method(req) {
  try query_params = http.get_query(req)
  try method = list.key_find(query_params, "_method")
  try method = http.parse_method(method)
  case method {
    Put | Patch | Delete -> Ok(method)
    _ -> Error(Nil)
  }
}

/// A middleware that overrides an incoming POST request with a method given in
/// the request's `_method` query paramerter. This is useful as web browsers
/// typically only support GET and POST requests, but our application may
/// expect other HTTP methods that are more semantically correct.
///
/// The methods PUT, PATCH, and DELETE are accepted for overriding, all others
/// are ignored.
///
/// The `_method` query paramerter can be specified in a HTML form like so:
///
///    <form method="POST" action="/item/1?_method=DELETE">
///      <button type="submit">Delete item</button>
///    </form>
///
pub fn method_override(service: Service(req, resp)) -> Service(req, resp) {
  fn(req) {
    req
    |> ensure_post
    |> result.then(get_override_method)
    |> result.map(http.set_method(req, _))
    |> result.unwrap(req)
    |> service
  }
}
