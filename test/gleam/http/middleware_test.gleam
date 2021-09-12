import gleam/http.{Delete, Get, Patch, Post, Put, Request, Response}
import gleam/http/middleware

pub fn method_override_test() {
  let service =
    fn(req: Request(a)) {
      http.response(200)
      |> http.set_resp_body(req.method)
    }
    |> middleware.method_override

  // No overriding without the query param
  assert Response(200, [], Get) =
    http.default_req()
    |> http.set_method(Get)
    |> service

  assert Response(200, [], Post) =
    http.default_req()
    |> http.set_method(Post)
    |> service

  // Can override
  assert Response(200, [], Delete) =
    http.default_req()
    |> http.set_method(Post)
    |> http.set_query([#("_method", "DELETE")])
    |> service

  assert Response(200, [], Patch) =
    http.default_req()
    |> http.set_method(Post)
    |> http.set_query([#("_method", "PATCH")])
    |> service

  assert Response(200, [], Put) =
    http.default_req()
    |> http.set_method(Post)
    |> http.set_query([#("_method", "PUT")])
    |> service

  // Cannot override with other methods
  assert Response(200, [], Post) =
    http.default_req()
    |> http.set_method(Post)
    |> http.set_query([#("_method", "OPTIONS")])
    |> service

  assert Response(200, [], Post) =
    http.default_req()
    |> http.set_method(Post)
    |> http.set_query([#("_method", "SOMETHING")])
    |> service
}
