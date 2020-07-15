//// Functions for working with HTTP data structures in Gleam.
////
//// This module makes it easy to create and modify Requests and Responses, data types.
//// A general HTTP message type is defined that enables functions to work on both requests and responses.
////
//// This module does not implement a HTTP client or HTTP server, but it can be used as a base for them.

// TODO: validate_req
// TODO: set_resp_header
// https://github.com/elixir-plug/plug/blob/dfebbebeb716c43c7dee4915a061bede06ec45f1/lib/plug/conn.ex#L776
// TODO: set_req_header
// https://github.com/elixir-plug/plug/blob/dfebbebeb716c43c7dee4915a061bede06ec45f1/lib/plug/conn.ex#L776
import gleam/list
import gleam/option.{None, Option, Some}
import gleam/string
import gleam/string_builder
import gleam/uri.{Uri}
import gleam/dynamic.{Dynamic}

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

/// The two URI schemes for HTTP
///
pub type Scheme {
  Http
  Https
}

/// Convert a scheme into a string.
///
/// # Examples
///
///    > scheme_to_string(Http)
///    "http"
///
///    > scheme_to_string(Https)
///    "https"
///
pub fn scheme_to_string(scheme: Scheme) -> String {
  case scheme {
    Http -> "http"
    Https -> "https"
  }
}

/// Parse a HTTP scheme from a string
///
/// # Examples
///
///    > scheme_to_string("http")
///    Ok(Http)
///
///    > scheme_to_string("ftp")
///    Error(Nil)
///
pub fn scheme_from_string(scheme: String) -> Result(Scheme, Nil) {
  case string.lowercase(scheme) {
    "http" -> Ok(Http)
    "https" -> Ok(Https)
    _ -> Error(Nil)
  }
}

pub external fn method_from_dynamic(Dynamic) -> Result(Method, Nil) =
  "gleam_http_native" "method_from_erlang"

/// A HTTP header is a key-value pair. Header keys should be all lowercase
/// characters.
pub type Header =
  tuple(String, String)

// TODO: document
pub type Request(body) {
  Request(
    method: Method,
    headers: List(Header),
    body: body,
    scheme: Scheme,
    host: String,
    port: Option(Int),
    path: String,
    query: Option(String),
  )
}

// TODO: document
pub type Response(body) {
  Response(status: Int, headers: List(Header), body: body)
}

// TODO: document
pub type Service(in, out) =
  fn(Request(in)) -> Response(out)

/// Return the uri that a request was sent to.
///
pub fn req_to_uri(request: Request(a)) -> Uri {
  Uri(
    scheme: Some(scheme_to_string(request.scheme)),
    userinfo: None,
    host: Some(request.host),
    port: request.port,
    path: request.path,
    query: request.query,
    fragment: None,
  )
}

/// Construct a request from a URI.
///
pub fn req_from_uri(uri: Uri) -> Result(Request(String), Nil) {
  try scheme = uri.scheme
    |> option.unwrap("")
    |> scheme_from_string
  try host = uri.host
    |> option.to_result(Nil)
  let req = Request(
    method: Get,
    headers: [],
    body: "",
    scheme: scheme,
    host: host,
    port: uri.port,
    path: uri.path,
    query: uri.query,
  )
  Ok(req)
}

/// Construct an empty Response.
///
/// The body type of the returned response is `Nil`, and should be set with a
/// call to `set_resp_body`.
///
pub fn response(status: Int) -> Response(Nil) {
  Response(status: status, headers: [], body: Nil)
}

/// Return the non-empty segments of a request path.
///
pub fn req_segments(request: Request(body)) -> List(String) {
  request.path
  |> uri.path_segments
}

/// Decode the query of a request.
pub fn get_query(
  request: Request(body),
) -> Result(List(tuple(String, String)), Nil) {
  case request.query {
    Some(query_string) -> uri.parse_query(query_string)
    None -> Ok([])
  }
}

// TODO: test
// TODO: escape
// TODO: record update syntax
/// Set the query of the request.
///
pub fn set_query(
  req: Request(body),
  query: List(tuple(String, String)),
) -> Request(body) {
  let pair = fn(t: tuple(String, String)) {
    string_builder.from_strings([t.0, "=", t.1])
  }
  let query = query
    |> list.map(pair)
    |> list.intersperse(string_builder.from_string("&"))
    |> string_builder.concat
    |> string_builder.to_string
    |> Some
  let Request(
    method: method,
    headers: headers,
    body: body,
    scheme: scheme,
    host: host,
    port: port,
    path: path,
    query: _,
  ) = req
  Request(
    method: method,
    headers: headers,
    body: body,
    scheme: scheme,
    host: host,
    port: port,
    path: path,
    query: query,
  )
}

/// Get the value for a given header.
///
/// If the request does not have that header then `Error(Nil)` is returned.
///
pub fn get_req_header(
  request: Request(body),
  key: String,
) -> Result(String, Nil) {
  list.key_find(request.headers, string.lowercase(key))
}

/// Get the value for a given header.
///
/// If the request does not have that header then `Error(Nil)` is returned.
///
pub fn get_resp_header(
  response: Response(body),
  key: String,
) -> Result(String, Nil) {
  list.key_find(response.headers, string.lowercase(key))
}

// TODO: use record update syntax
// TODO: document
// TODO: test
// https://github.com/elixir-plug/plug/blob/dfebbebeb716c43c7dee4915a061bede06ec45f1/lib/plug/conn.ex#L809
pub fn prepend_req_header(
  request: Request(body),
  key: String,
  value: String,
) -> Request(body) {
  let Request(method, headers, body, scheme, host, port, path, query) = request
  let headers = [tuple(string.lowercase(key), value), ..headers]
  Request(method, headers, body, scheme, host, port, path, query)
}

// TODO: use record update syntax
// TODO: document
// https://github.com/elixir-plug/plug/blob/dfebbebeb716c43c7dee4915a061bede06ec45f1/lib/plug/conn.ex#L809
pub fn prepend_resp_header(
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
pub fn set_resp_body(
  response: Response(old_body),
  body: new_body,
) -> Response(new_body) {
  let Response(status: status, headers: headers, ..) = response
  Response(status: status, headers: headers, body: body)
}

// TODO: test
// TODO: record update syntax
/// Set the body of the request, overwriting any existing body.
///
pub fn set_req_body(
  req: Request(old_body),
  body: new_body,
) -> Request(new_body) {
  let Request(
    method: method,
    headers: headers,
    scheme: scheme,
    host: host,
    port: port,
    path: path,
    query: query,
    ..,
  ) = req
  Request(
    method: method,
    headers: headers,
    body: body,
    scheme: scheme,
    host: host,
    port: port,
    path: path,
    query: query,
  )
}

// TODO: test
// TODO: record update syntax
/// Set the method of the request.
///
pub fn set_method(req: Request(body), method: Method) -> Request(body) {
  let Request(
    method: _,
    headers: headers,
    body: body,
    scheme: scheme,
    host: host,
    port: port,
    path: path,
    query: query,
  ) = req
  Request(
    method: method,
    headers: headers,
    body: body,
    scheme: scheme,
    host: host,
    port: port,
    path: path,
    query: query,
  )
}

// TODO: test
/// Update the body of a response using a given function.
///
pub fn map_resp_body(
  response: Response(old_body),
  transform: fn(old_body) -> new_body,
) -> Response(new_body) {
  response.body
  |> transform
  |> set_resp_body(response, _)
}

// TODO: test
/// Update the body of a request using a given function.
///
pub fn map_req_body(
  request: Request(old_body),
  transform: fn(old_body) -> new_body,
) -> Request(new_body) {
  request.body
  |> transform
  |> set_req_body(request, _)
}

// TODO: test
/// Update the body of a response using a given result returning function.
///
/// If the given function returns an `Ok` value the body is set, if it returns
/// an `Error` value then the error is returned.
///
pub fn try_map_resp_body(
  response: Response(old_body),
  transform: fn(old_body) -> Result(new_body, error),
) -> Result(Response(new_body), error) {
  try body = transform(response.body)
  Ok(set_resp_body(response, body))
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

/// A request with commonly used default values. This request can be used as a
/// an initial value and then update to create the desired request.
///
pub fn default_req() -> Request(String) {
  Request(
    method: Get,
    headers: [],
    body: "",
    scheme: Https,
    host: "localhost",
    port: None,
    path: "",
    query: None,
  )
}

// TODO: test
// TODO: record update syntax
/// Set the method of the request.
///
pub fn set_req_host(req: Request(body), host: String) -> Request(body) {
  let Request(
    method: method,
    headers: headers,
    body: body,
    scheme: scheme,
    host: _,
    port: port,
    path: path,
    query: query,
  ) = req
  Request(
    method: method,
    headers: headers,
    body: body,
    scheme: scheme,
    host: host,
    port: port,
    path: path,
    query: query,
  )
}

// TODO: test
// TODO: record update syntax
/// Set the method of the request.
///
pub fn set_req_path(req: Request(body), path: String) -> Request(body) {
  let Request(
    method: method,
    headers: headers,
    body: body,
    scheme: scheme,
    host: host,
    port: port,
    path: _,
    query: query,
  ) = req
  Request(
    method: method,
    headers: headers,
    body: body,
    scheme: scheme,
    host: host,
    port: port,
    path: path,
    query: query,
  )
}
