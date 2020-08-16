# Gleam HTTP

Types and functions for HTTP clients and servers!

## HTTP Service Example

```rust
import gleam/http/elli
import gleam/http.{Request, Response}
import gleam/bit_builder.{BitBuilder}
import gleam/bit_string

// Define a HTTP service
//
pub fn my_service(req: Request(BitString)) -> Response(BitBuilder) {
  let body = "Hello, world!"
    |> bit_string.from_string
    |> bit_builder.from_bit_string

  http.response(200)
  |> http.prepend_resp_header("made-with", "Gleam")
  |> http.set_resp_body(body)
}

// Start it on port 3000 using the Elli web server
//
pub fn start() {
  elli.start(my_service, on_port: 3000)
}
```

In the example above the Elli Erlang web server is used to run the Gleam HTTP
service. Here's a full list of the adapters available, sorted alphabetically.

| Adapter                  | About                                                              |
| ---                      | ---                                                                |
| [Cowboy][cowboy-adapter] | [Cowboy][cowboy] is a HTTP2 & HTTP1.1 web server written in Erlang |
| [Elli][elli-adapter]     | [Elli][elli] is a HTTP1.1 web server written in Erlang             |

[cowboy]:https://github.com/ninenines/cowboy
[cowboy-adapter]: https://github.com/gleam-experiments/cowboy
[elli]:https://github.com/elli-lib/elli
[elli-adapter]: https://github.com/gleam-experiments/elli
