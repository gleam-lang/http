import gleam/http.{type Header, type Method, type Scheme, Get}
import gleam/http/cookie
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import gleam/string_builder
import gleam/uri.{type Uri, Uri}

/// A HTTP request.
///
/// The body of the request is parameterised. The HTTP server or client you are
/// using will have a particular set of types it supports for the body.
/// 
pub type Request(body) {
  Request(
    method: Method,
    /// The request headers. The keys must always be lowercase.
    headers: List(Header),
    body: body,
    scheme: Scheme,
    host: String,
    port: Option(Int),
    path: String,
    query: Option(String),
  )
}

/// Return the uri that a request was sent to.
///
pub fn to_uri(request: Request(a)) -> Uri {
  Uri(
    scheme: option.Some(http.scheme_to_string(request.scheme)),
    userinfo: option.None,
    host: option.Some(request.host),
    port: request.port,
    path: request.path,
    query: request.query,
    fragment: option.None,
  )
}

/// Construct a request from a URI.
///
pub fn from_uri(uri: Uri) -> Result(Request(String), Nil) {
  use scheme <- result.then(
    uri.scheme
    |> option.unwrap("")
    |> http.scheme_from_string,
  )
  use host <- result.then(
    uri.host
    |> option.to_result(Nil),
  )
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

/// Get the value for a given header.
///
/// If the request does not have that header then `Error(Nil)` is returned.
///
/// Header keys are always lowercase in `gleam_http`. To use any uppercase
/// letter is invalid.
///
pub fn get_header(request: Request(body), key: String) -> Result(String, Nil) {
  list.key_find(request.headers, string.lowercase(key))
}

/// Set the header with the given value under the given header key.
///
/// If already present, it is replaced.
///
/// Header keys are always lowercase in `gleam_http`. To use any uppercase
/// letter is invalid.
///
pub fn set_header(
  request: Request(body),
  key: String,
  value: String,
) -> Request(body) {
  let headers = list.key_set(request.headers, string.lowercase(key), value)
  Request(..request, headers: headers)
}

/// Prepend the header with the given value under the given header key.
///
/// Similar to `set_header` except if the header already exists it prepends
/// another header with the same key.
///
/// Header keys are always lowercase in `gleam_http`. To use any uppercase
/// letter is invalid.
///
pub fn prepend_header(
  request: Request(body),
  key: String,
  value: String,
) -> Request(body) {
  let headers = [#(string.lowercase(key), value), ..request.headers]
  Request(..request, headers: headers)
}

// TODO: record update syntax, which can't be done currently as body type changes
/// Set the body of the request, overwriting any existing body.
///
pub fn set_body(req: Request(old_body), body: new_body) -> Request(new_body) {
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

/// Update the body of a request using a given function.
///
pub fn map(
  request: Request(old_body),
  transform: fn(old_body) -> new_body,
) -> Request(new_body) {
  request.body
  |> transform
  |> set_body(request, _)
}

/// Return the non-empty segments of a request path.
///
/// # Examples
///
/// ```gleam
/// > new()
/// > |> set_path("/one/two/three")
/// > |> path_segments
/// ["one", "two", "three"]
/// ```
///
pub fn path_segments(request: Request(body)) -> List(String) {
  request.path
  |> uri.path_segments
}

/// Decode the query of a request.
pub fn get_query(request: Request(body)) -> Result(List(#(String, String)), Nil) {
  case request.query {
    option.Some(query_string) -> uri.parse_query(query_string)
    option.None -> Ok([])
  }
}

/// Set the query of the request.
/// Query params will be percent encoded before being added to the Request.
///
pub fn set_query(
  req: Request(body),
  query: List(#(String, String)),
) -> Request(body) {
  let pair = fn(t: #(String, String)) {
    string_builder.from_strings([
      uri.percent_encode(t.0),
      "=",
      uri.percent_encode(t.1),
    ])
  }
  let query =
    query
    |> list.map(pair)
    |> list.intersperse(string_builder.from_string("&"))
    |> string_builder.concat
    |> string_builder.to_string
    |> option.Some
  Request(..req, query: query)
}

/// Set the method of the request.
///
pub fn set_method(req: Request(body), method: Method) -> Request(body) {
  Request(..req, method: method)
}

/// A request with commonly used default values. This request can be used as
/// an initial value and then update to create the desired request.
///
pub fn new() -> Request(String) {
  Request(
    method: Get,
    headers: [],
    body: "",
    scheme: http.Https,
    host: "localhost",
    port: option.None,
    path: "",
    query: option.None,
  )
}

/// Construct a request from a URL string
///
pub fn to(url: String) -> Result(Request(String), Nil) {
  url
  |> uri.parse
  |> result.then(from_uri)
}

/// Set the scheme (protocol) of the request.
///
pub fn set_scheme(req: Request(body), scheme: Scheme) -> Request(body) {
  Request(..req, scheme: scheme)
}

/// Set the host of the request.
///
pub fn set_host(req: Request(body), host: String) -> Request(body) {
  Request(..req, host: host)
}

/// Set the port of the request.
///
pub fn set_port(req: Request(body), port: Int) -> Request(body) {
  Request(..req, port: option.Some(port))
}

/// Set the path of the request.
///
pub fn set_path(req: Request(body), path: String) -> Request(body) {
  Request(..req, path: path)
}

/// Send a cookie with a request
///
/// Multiple cookies are added to the same cookie header.
pub fn set_cookie(req: Request(body), name: String, value: String) {
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

/// Fetch the cookies sent in a request.
///
/// Note badly formed cookie pairs will be ignored.
/// RFC6265 specifies that invalid cookie names/attributes should be ignored.
pub fn get_cookies(req) -> List(#(String, String)) {
  let Request(headers: headers, ..) = req

  headers
  |> list.filter_map(fn(header) {
    let #(name, value) = header
    case name {
      "cookie" -> Ok(cookie.parse(value))
      _ -> Error(Nil)
    }
  })
  |> list.flatten()
}

/// Remove a cookie from a request
///
/// Remove a cookie from the request. If no cookie is found return the request unchanged.
/// This will not remove the cookie from the client.
pub fn remove_cookie(req: Request(body), name: String) {
  case list.key_pop(req.headers, "cookie") {
    Ok(#(cookies_string, headers)) -> {
      let new_cookies_string =
        string.split(cookies_string, ";")
        |> list.filter(fn(str) {
          string.trim(str)
          |> string.split_once("=")
          // Keep cookie if name does not match
          |> result.map(fn(tup) { tup.0 != name })
          // Don't do anything with malformed cookies
          |> result.unwrap(True)
        })
        |> string.join(";")

      Request(..req, headers: [#("cookie", new_cookies_string), ..headers])
    }
    Error(_) -> req
  }
}
