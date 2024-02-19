import gleam/http.{Delete, Patch, Post, Put}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/list
import gleam/result

@deprecated("Use middleware packages such as Wisp or Glen instead")
pub type Service(in, out) =
  fn(Request(in)) -> Response(out)

@deprecated("Use middleware packages such as Wisp or Glen instead")
pub type Middleware(before_req, before_resp, after_req, after_resp) =
  fn(fn(Request(before_req)) -> Response(before_resp)) ->
    fn(Request(after_req)) -> Response(after_resp)

@deprecated("Use middleware packages such as Wisp or Glen instead")
pub fn map_response_body(service, with mapper: fn(a) -> b) {
  fn(req) {
    req
    |> service
    |> response.map(mapper)
  }
}

@deprecated("Use middleware packages such as Wisp or Glen instead")
pub fn prepend_response_header(service, key: String, value: String) {
  fn(req) {
    req
    |> service
    |> response.prepend_header(key, value)
  }
}

fn ensure_post(req: Request(a)) {
  case req.method {
    Post -> Ok(req)
    _ -> Error(Nil)
  }
}

fn get_override_method(request: Request(t)) -> Result(http.Method, Nil) {
  use query_params <- result.then(request.get_query(request))
  use method <- result.then(list.key_find(query_params, "_method"))
  use method <- result.then(http.parse_method(method))
  case method {
    Put | Patch | Delete -> Ok(method)
    _ -> Error(Nil)
  }
}

@deprecated("Use middleware packages such as Wisp or Glen instead")
pub fn method_override(service) {
  fn(request) {
    request
    |> ensure_post
    |> result.then(get_override_method)
    |> result.map(request.set_method(request, _))
    |> result.unwrap(request)
    |> service
  }
}
