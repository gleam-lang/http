# Gleam HTTP

Types and functions for HTTP clients and servers!

## HTTP Service Example

```rust
import gleam/http
import gleam/elli
import gleam/bit_string
import gleam/bit_builder

// Define a HTTP service
//
pub fn my_service(req: http.Request) -> http.Response {
  let body = "Hello, world!"
    |> bit_string.from_string
    |> bit_builder.from_bit_string

  http.response(200)
  |> http.put_resp_header("made-with", "Gleam")
  |> http.put_resp_body(body)
}

// Start it on port 3000 using the Elli web server
//
pub fn start() {
  elli.start(my_service, on_port: 3000)
}
```
