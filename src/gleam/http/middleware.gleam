import gleam/http.{Request, Response, Service}

pub type Middleware(before_req, before_resp, after_req, after_resp) =
  fn(Service(before_req, before_resp)) -> Service(after_req, after_resp)

/// A middleware that transform the response body returned by the service using
/// a given function.
///
pub fn map_response_body(
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
