import gleam/http.{Delete, Get, Patch, Post, Put}
import gleam/http/response.{Response}
import gleam/http/request.{Request}
import gleam/http/service

pub fn method_override_test() {
  let service =
    fn(req: Request(a)) {
      response.new(200)
      |> response.set_body(req.method)
    }
    |> service.method_override

  // No overriding without the query param
  assert Response(200, [], Get) =
    request.new()
    |> request.set_method(Get)
    |> service

  assert Response(200, [], Post) =
    request.new()
    |> request.set_method(Post)
    |> service

  // Can override
  assert Response(200, [], Delete) =
    request.new()
    |> request.set_method(Post)
    |> request.set_query([#("_method", "DELETE")])
    |> service

  assert Response(200, [], Patch) =
    request.new()
    |> request.set_method(Post)
    |> request.set_query([#("_method", "PATCH")])
    |> service

  assert Response(200, [], Put) =
    request.new()
    |> request.set_method(Post)
    |> request.set_query([#("_method", "PUT")])
    |> service

  // Cannot override with other methods
  assert Response(200, [], Post) =
    request.new()
    |> request.set_method(Post)
    |> request.set_query([#("_method", "OPTIONS")])
    |> service

  assert Response(200, [], Post) =
    request.new()
    |> request.set_method(Post)
    |> request.set_query([#("_method", "SOMETHING")])
    |> service
}
