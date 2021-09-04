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
import gleam/bit_string
import gleam/dynamic.{Dynamic}
import gleam/int
import gleam/list
import gleam/option.{None, Option, Some}
import gleam/regex
import gleam/result
import gleam/string
import gleam/string_builder
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
  #(String, String)

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
    userinfo: option.None,
    host: Some(request.host),
    port: request.port,
    path: request.path,
    query: request.query,
    fragment: option.None,
  )
}

/// Construct a request from a URI.
///
pub fn req_from_uri(uri: Uri) -> Result(Request(String), Nil) {
  try scheme =
    uri.scheme
    |> option.unwrap("")
    |> scheme_from_string
  try host =
    uri.host
    |> option.to_result(Nil)
  let req =
    Request(
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
pub fn path_segments(request: Request(body)) -> List(String) {
  request.path
  |> uri.path_segments
}

/// Decode the query of a request.
pub fn get_query(request: Request(body)) -> Result(List(#(String, String)), Nil) {
  case request.query {
    Some(query_string) -> uri.parse_query(query_string)
    option.None -> Ok([])
  }
}

// TODO: escape
/// Set the query of the request.
///
pub fn set_query(
  req: Request(body),
  query: List(#(String, String)),
) -> Request(body) {
  let pair = fn(t: #(String, String)) {
    string_builder.from_strings([t.0, "=", t.1])
  }
  let query =
    query
    |> list.map(pair)
    |> list.intersperse(string_builder.from_string("&"))
    |> string_builder.concat
    |> string_builder.to_string
    |> Some
  Request(..req, query: query)
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

// TODO: document
// https://github.com/elixir-plug/plug/blob/dfebbebeb716c43c7dee4915a061bede06ec45f1/lib/plug/conn.ex#L809
pub fn prepend_req_header(
  request: Request(body),
  key: String,
  value: String,
) -> Request(body) {
  let headers = [#(string.lowercase(key), value), ..request.headers]
  Request(..request, headers: headers)
}

// TODO: document
// https://github.com/elixir-plug/plug/blob/dfebbebeb716c43c7dee4915a061bede06ec45f1/lib/plug/conn.ex#L809
pub fn prepend_resp_header(
  response: Response(body),
  key: String,
  value: String,
) -> Response(body) {
  let headers = [#(string.lowercase(key), value), ..response.headers]
  Response(..response, headers: headers)
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

// TODO: record update syntax
/// Set the body of the request, overwriting any existing body.
///
pub fn set_req_body(req: Request(old_body), body: new_body) -> Request(new_body) {
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

/// Set the method of the request.
///
pub fn set_method(req: Request(body), method: Method) -> Request(body) {
  Request(..req, method: method)
}

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
    headers: [#("location", uri)],
    body: string.append("You are being redirected to ", uri),
  )
}

/// A request with commonly used default values. This request can be used as
/// an initial value and then update to create the desired request.
///
pub fn default_req() -> Request(String) {
  Request(
    method: Get,
    headers: [],
    body: "",
    scheme: Https,
    host: "localhost",
    port: option.None,
    path: "",
    query: option.None,
  )
}

/// Set the scheme (protocol) of the request.
///
pub fn set_scheme(req: Request(body), scheme: Scheme) -> Request(body) {
  Request(..req, scheme: scheme)
}

/// Set the method of the request.
///
pub fn set_host(req: Request(body), host: String) -> Request(body) {
  Request(..req, host: host)
}

/// Set the port of the request.
///
pub fn set_port(req: Request(body), port: Int) -> Request(body) {
  Request(..req, port: Some(port))
}

/// Set the path of the request.
///
pub fn set_path(req: Request(body), path: String) -> Request(body) {
  Request(..req, path: path)
}

fn check_token(token: BitString) {
  case token {
    <<"":utf8>> -> Ok(Nil)
    <<" ":utf8, _>> -> Error(Nil)
    <<"\t":utf8, _>> -> Error(Nil)
    <<"\r":utf8, _>> -> Error(Nil)
    <<"\n":utf8, _>> -> Error(Nil)
    <<"\f":utf8, _>> -> Error(Nil)
    <<_, rest:bit_string>> -> check_token(rest)
  }
}

fn parse_cookie_list(cookie_string) {
  assert Ok(re) = regex.from_string("[,;]")
  regex.split(re, cookie_string)
  |> list.filter_map(fn(pair) {
    case string.split_once(string.trim(pair), "=") {
      Ok(#("", _)) -> Error(Nil)
      Ok(#(key, value)) -> {
        let key = string.trim(key)
        let value = string.trim(value)
        try _ = check_token(bit_string.from_string(key))
        try _ = check_token(bit_string.from_string(value))
        Ok(#(key, value))
      }
      Error(Nil) -> Error(Nil)
    }
  })
}

/// Fetch the cookies sent in a request.
///
/// Note badly formed cookie pairs will be ignored.
/// RFC6265 specifies that invalid cookie names/attributes should be ignored.
pub fn get_req_cookies(req) -> List(#(String, String)) {
  let Request(headers: headers, ..) = req

  headers
  |> list.filter_map(fn(header) {
    let #(name, value) = header
    case name {
      "cookie" -> Ok(parse_cookie_list(value))
      _ -> Error(Nil)
    }
  })
  |> list.flatten()
}

const epoch = "Expires=Thu, 01 Jan 1970 00:00:00 GMT"

/// Policy options for the SameSite cookie attribute
///
/// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie/SameSite
pub type SameSitePolicy {
  Lax
  Strict
  None
}

fn same_site_to_string(policy) {
  case policy {
    Lax -> "Lax"
    Strict -> "Strict"
    None -> "None"
  }
}

/// Send a cookie with a request
///
/// Multiple cookies are added to the same cookie header.
pub fn set_req_cookie(req: Request(body), name: String, value: String) {
  let new_cookie_string = string.join([name, value], "=")

  let #(cookies_string, headers) = case list.key_pop(req.headers, "cookie") {
    Ok(#(cookies_string, headers)) -> {
      let cookies_string =
        string.join([cookies_string, new_cookie_string], "; ")
      #(cookies_string, headers)
    }
    Error(Nil) -> #(new_cookie_string, req.headers)
  }

  Request(..req, headers: [#("cookie", cookies_string), ..headers])
}

/// Attributes of a cookie when sent to a client in the `set-cookie` header.
pub type CookieAttributes {
  CookieAttributes(
    max_age: Option(Int),
    domain: Option(String),
    path: Option(String),
    secure: Bool,
    http_only: Bool,
    same_site: Option(SameSitePolicy),
  )
}

/// Helper to create sensible default attributes for a set cookie.
///
/// Note these defaults may not be sufficient to secure your application.
/// You should consider setting the SameSite field.
///
/// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#Attributes
pub fn cookie_defaults(scheme: Scheme) {
  CookieAttributes(
    max_age: option.None,
    domain: option.None,
    path: Some("/"),
    secure: scheme == Https,
    http_only: True,
    same_site: option.None,
  )
}

fn cookie_attributes_to_list(attributes) {
  let CookieAttributes(
    max_age: max_age,
    domain: domain,
    path: path,
    secure: secure,
    http_only: http_only,
    same_site: same_site,
  ) = attributes
  [
    // Expires is a deprecated attribute for cookies, it has been replaced with MaxAge
    // MaxAge is widely supported and so Expires values are not set.
    // Only when deleting cookies is the exception made to use the old format,
    // to ensure complete clearup of cookies if required by an application.
    case max_age {
      Some(0) -> Some([epoch])
      _ -> option.None
    },
    option.map(max_age, fn(max_age) { ["Max-Age=", int.to_string(max_age)] }),
    option.map(domain, fn(domain) { ["Domain=", domain] }),
    option.map(path, fn(path) { ["Path=", path] }),
    case secure {
      True -> Some(["Secure"])
      False -> option.None
    },
    case http_only {
      True -> Some(["HttpOnly"])
      False -> option.None
    },
    option.map(
      same_site,
      fn(same_site) { ["SameSite=", same_site_to_string(same_site)] },
    ),
  ]
  |> list.filter_map(option.to_result(_, Nil))
}

/// Fetch the cookies sent in a response
///
/// Follows the same logic as fetching the cookie from the request
/// (i.e. badly formed cookies will be ignored)
pub fn get_resp_cookies(resp) -> List(#(String, String)) {
  let Response(headers: headers, ..) = resp
  headers
  |> list.filter_map(fn(header) {
    let #(name, value) = header
    case name {
      "set-cookie" -> Ok(parse_cookie_list(value))
      _ -> Error(Nil)
    }
  })
  |> list.flatten()
}

/// Deprecated. Use `get_resp_cookies` instead.
pub fn get_resp_cookie(resp) {
  get_resp_cookies(resp)
}

/// Set a cookie value for a client
///
/// The attributes record is defined in `gleam/http/cookie`
pub fn set_resp_cookie(resp, name, value, attributes) {
  let header_value =
    [[name, "=", value], ..cookie_attributes_to_list(attributes)]
    |> list.map(string.join(_, ""))
    |> string.join("; ")
  prepend_resp_header(resp, "set-cookie", header_value)
}

/// Expire a cookie value for a client
///
/// Not the attributes value should be the same as when the response cookie was set.
pub fn expire_resp_cookie(resp, name, attributes) {
  let attrs = CookieAttributes(..attributes, max_age: Some(0))
  set_resp_cookie(resp, name, "", attrs)
}

/// Get the origin request header
///
/// If no "origin" header is found in the request, falls back to the "referer"
/// header.
pub fn get_req_origin(req: Request(body)) -> Result(String, Nil) {
  get_req_header(req, "origin")
  |> result.lazy_or(fn() {
    try ref = get_req_header(req, "referer")
    ref
    |> uri.parse
    |> uri.origin
  })
}
