//// Functions for working with HTTP data structures in Gleam.
////
//// This module makes it easy to create and modify Requests and Responses, data types.
//// A general HTTP message type is defined that enables functions to work on both requests and responses.
////
//// This module does not implement a HTTP client or HTTP server, but it can be used as a base for them.

// TODO: set_response_header
// https://github.com/elixir-plug/plug/blob/dfebbebeb716c43c7dee4915a061bede06ec45f1/lib/plug/conn.ex#L776
// TODO: set_request_header
// https://github.com/elixir-plug/plug/blob/dfebbebeb716c43c7dee4915a061bede06ec45f1/lib/plug/conn.ex#L776
import gleam/list
import gleam/option.{None, Option, Some}
import gleam/string
import gleam/uri.{Uri}

/// HTTP standard method as defined by [RFC 2616](https://tools.ietf.org/html/rfc2616),
/// and PATCH which is defined by [RFC 5789](https://tools.ietf.org/html/rfc5789).
pub type Method {
  Get
  Post
  Head
  Put
  Delete
  Trace
  Connect
  Options
  Patch

  /// Non-standard but valid HTTP methods.
  Other(String)
}

// TODO: check if the a is a valid HTTP method (i.e. it is a token, as per the
// spec) and return Ok(Other(s)) if so.
pub fn parse_method(s) {
  case string.lowercase(s) {
    "connect" -> Ok(Connect)
    "delete" -> Ok(Delete)
    "get" -> Ok(Get)
    "head" -> Ok(Head)
    "options" -> Ok(Options)
    "patch" -> Ok(Patch)
    "post" -> Ok(Post)
    "put" -> Ok(Put)
    "trace" -> Ok(Trace)
    _ -> Error(Nil)
  }
}

pub fn method_to_string(method) {
  case method {
    Connect -> "connect"
    Delete -> "delete"
    Get -> "get"
    Head -> "head"
    Options -> "options"
    Patch -> "patch"
    Post -> "post"
    Put -> "put"
    Trace -> "trace"
    Other(s) -> s
  }
}

// TODO: document
pub type Scheme {
  Http
  Https
}

// TODO: test
// TODO: document
pub fn scheme_to_string(scheme: Scheme) -> String {
  case scheme {
    Http -> "http"
    Https -> "https"
  }
}

// TODO: test
// TODO: document
pub fn scheme_from_string(scheme: String) -> Result(Scheme, Nil) {
  case string.lowercase(scheme) {
    "http" -> Ok(Http)
    "https" -> Ok(Https)
    _ -> Error(Nil)
  }
}

pub external fn method_from_erlang(anything) -> Result(Method, Nil) =
  "gleam_http_native" "method_from_erlang"

/// A HTTP header is a key-value pair. Header keys should be all lowercase
/// characters.
pub type Header =
  tuple(String, String)

// TODO: document
pub type Request(body) {
  Request(
    method: Method,
    host: String,
    port: Option(Int),
    path: String,
    query: Option(String),
    headers: List(Header),
    body: body,
  )
}

// TODO: document
pub type Response(body) {
  Response(status: Int, headers: List(Header), body: body)
}

/// Return the uri that a request was sent to.
///
pub fn request_uri(request: Request(a), scheme: Scheme) -> Uri {
  Uri(
    scheme: Some(scheme_to_string(scheme)),
    userinfo: None,
    host: Some(request.host),
    port: request.port,
    path: request.path,
    query: request.query,
    fragment: None,
  )
}

/// Construct an empty Response.
///
/// The body type of the returned response is `Nil`, and should be set with a
/// call to `set_response_body`.
///
pub fn response(status: Int) -> Response(Nil) {
  Response(status: status, headers: [], body: Nil)
}

/// Return the non-empty segments of a request path.
///
pub fn request_segments(request: Request(body)) -> List(String) {
  request.path
  |> uri.path_segments
}

/// Decode the query of a request.
pub fn request_query(
  request: Request(body),
) -> Result(List(tuple(String, String)), Nil) {
  case request.query {
    Some(query_string) -> uri.parse_query(query_string)
    None -> Ok([])
  }
}

/// Get the value for a given header.
///
/// If the request does not have that header then `Error(Nil)` is returned.
///
pub fn request_header(
  request: Request(body),
  key: String,
) -> Result(String, Nil) {
  list.key_find(request.headers, string.lowercase(key))
}

/// Get the value for a given header.
///
/// If the request does not have that header then `Error(Nil)` is returned.
///
pub fn response_header(
  response: Response(body),
  key: String,
) -> Result(String, Nil) {
  list.key_find(response.headers, string.lowercase(key))
}

// TODO: use record update syntax
// TODO: document
// TODO: test
// https://github.com/elixir-plug/plug/blob/dfebbebeb716c43c7dee4915a061bede06ec45f1/lib/plug/conn.ex#L809
pub fn prepend_request_header(
  request: Request(body),
  key: String,
  value: String,
) -> Request(body) {
  let Request(method, host, port, path, query, headers, body) = request
  let headers = [tuple(string.lowercase(key), value), ..headers]
  Request(method, host, port, path, query, headers, body)
}

// TODO: use record update syntax
// TODO: document
// https://github.com/elixir-plug/plug/blob/dfebbebeb716c43c7dee4915a061bede06ec45f1/lib/plug/conn.ex#L809
pub fn prepend_response_header(
  response: Response(body),
  key: String,
  value: String,
) -> Response(body) {
  let Response(status, headers, body) = response
  let headers = [tuple(string.lowercase(key), value), ..headers]
  Response(status, headers, body)
}

/// Set the body of the response, overwriting any existing body.
///
pub fn set_response_body(
  response: Response(old_body),
  body: new_body,
) -> Response(new_body) {
  let Response(status: status, headers: headers, ..) = response
  Response(status: status, headers: headers, body: body)
}

// TODO: test
/// Update the body of a response using a given function.
///
pub fn map_response_body(
  response: Response(old_body),
  transform: fn(old_body) -> new_body,
) -> Response(new_body) {
  response.body
  |> transform
  |> set_response_body(response, _)
}

// TODO: test
/// Update the body of a response using a given result returning function.
///
/// If the given function returns an `Ok` value the body is set, if it returns
/// an `Error` value then the error is returned.
///
pub fn try_map_response_body(
  response: Response(old_body),
  transform: fn(old_body) -> Result(new_body, error),
) -> Result(Response(new_body), error) {
  try body = transform(response.body)
  Ok(set_response_body(response, body))
}

/// Create a response that redirects to the given uri.
///
pub fn redirect(uri: String) -> Response(String) {
  Response(
    status: 303,
    headers: [tuple("location", uri)],
    body: string.append("You are being redirected to ", uri),
  )
}
