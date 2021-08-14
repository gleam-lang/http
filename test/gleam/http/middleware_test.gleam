import gleam/should
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
  http.default_req()
  |> http.set_method(Get)
  |> service
  |> should.equal(Response(200, [], Get))

  http.default_req()
  |> http.set_method(Post)
  |> service
  |> should.equal(Response(200, [], Post))

  // Can override
  http.default_req()
  |> http.set_method(Post)
  |> http.set_query([#("_method", "DELETE")])
  |> service
  |> should.equal(Response(200, [], Delete))

  http.default_req()
  |> http.set_method(Post)
  |> http.set_query([#("_method", "PATCH")])
  |> service
  |> should.equal(Response(200, [], Patch))

  http.default_req()
  |> http.set_method(Post)
  |> http.set_query([#("_method", "PUT")])
  |> service
  |> should.equal(Response(200, [], Put))

  // Cannot override with other methods
  http.default_req()
  |> http.set_method(Post)
  |> http.set_query([#("_method", "OPTIONS")])
  |> service
  |> should.equal(Response(200, [], Post))

  http.default_req()
  |> http.set_method(Post)
  |> http.set_query([#("_method", "SOMETHING")])
  |> service
  |> should.equal(Response(200, [], Post))
}
