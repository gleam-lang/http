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
  let assert Response(200, [], Get) =
    request.new("http://localhost")
    |> request.set_method(Get)
    |> service

  let assert Response(200, [], Post) =
    request.new("http://localhost")
    |> request.set_method(Post)
    |> service

  // Can override
  let assert Response(200, [], Delete) =
    request.new("http://localhost")
    |> request.set_method(Post)
    |> request.set_query([#("_method", "DELETE")])
    |> service

  let assert Response(200, [], Patch) =
    request.new("http://localhost")
    |> request.set_method(Post)
    |> request.set_query([#("_method", "PATCH")])
    |> service

  let assert Response(200, [], Put) =
    request.new("http://localhost")
    |> request.set_method(Post)
    |> request.set_query([#("_method", "PUT")])
    |> service

  // Cannot override with other methods
  let assert Response(200, [], Post) =
    request.new("http://localhost")
    |> request.set_method(Post)
    |> request.set_query([#("_method", "OPTIONS")])
    |> service

  let assert Response(200, [], Post) =
    request.new("http://localhost")
    |> request.set_method(Post)
    |> request.set_query([#("_method", "SOMETHING")])
    |> service
}
