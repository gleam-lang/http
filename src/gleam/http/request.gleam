import gleam/http.{type Header, type Method, type Scheme, Get}
import gleam/http/cookie
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
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
pub fn to_uri(request: Request(body)) -> Uri {
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
  use scheme <- result.try(
    uri.scheme
    |> option.unwrap("")
    |> http.scheme_from_string,
  )
  use host <- result.try(
    uri.host
    |> option.to_result(Nil),
  )
  let req =
    Request(
      method: Get,
      headers: [],
      body: "",
      scheme:,
      host:,
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
  Request(..request, headers:)
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
  Request(..request, headers:)
}

/// Set the body of the request, overwriting any existing body.
///
pub fn set_body(req: Request(old_body), body: new_body) -> Request(new_body) {
  Request(..req, body:)
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
  let query =
    list.map(query, fn(pair) {
      let #(key, value) = pair
      uri.percent_encode(key) <> "=" <> uri.percent_encode(value)
    })
    |> string.join(with: "&")
    |> option.Some

  Request(..req, query:)
}

/// Set the method of the request.
///
pub fn set_method(req: Request(body), method: Method) -> Request(body) {
  Request(..req, method:)
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
  |> result.try(from_uri)
}

/// Set the scheme (protocol) of the request.
///
pub fn set_scheme(req: Request(body), scheme: Scheme) -> Request(body) {
  Request(..req, scheme:)
}

/// Set the host of the request.
///
pub fn set_host(req: Request(body), host: String) -> Request(body) {
  Request(..req, host:)
}

/// Set the port of the request.
///
pub fn set_port(req: Request(body), port: Int) -> Request(body) {
  Request(..req, port: option.Some(port))
}

/// Set the path of the request.
///
pub fn set_path(req: Request(body), path: String) -> Request(body) {
  Request(..req, path:)
}

/// Set a cookie on a request, replacing any previous cookie with that name.
///
/// All cookies should be stored in a single header named `cookie`.
/// There should be at most one header with the name `cookie`, otherwise this
/// function cannot guarentee that previous cookies with the same name are
/// replaced.
///
pub fn set_cookie(
  req: Request(body),
  name: String,
  value: String,
) -> Request(body) {
  // Get the cookies
  let #(cookies, headers) =
    list.key_pop(req.headers, "cookie") |> result.unwrap(#("", req.headers))

  // Set the new cookie, replacing any previous one with the same name
  let cookies =
    cookie.parse(cookies)
    |> list.key_set(name, value)
    |> list.map(fn(pair) { pair.0 <> "=" <> pair.1 })
    |> string.join("; ")

  Request(..req, headers: [#("cookie", cookies), ..headers])
}

/// Fetch the cookies sent in a request.
///
/// Note badly formed cookie pairs will be ignored.
/// RFC6265 specifies that invalid cookie names/attributes should be ignored.
pub fn get_cookies(req: Request(body)) -> List(#(String, String)) {
  let Request(headers:, ..) = req

  list.flat_map(headers, fn(header) {
    case header {
      #("cookie", value) -> cookie.parse(value)
      _ -> []
    }
  })
}

/// Remove a cookie from a request
///
/// Remove a cookie from the request. If no cookie is found return the request
/// unchanged. This will not remove the cookie from the client.
pub fn remove_cookie(req: Request(body), name: String) -> Request(body) {
  case list.key_pop(req.headers, "cookie") {
    Ok(#(cookies_string, headers)) -> {
      let new_cookies_string =
        cookie.parse(cookies_string)
        |> list.filter_map(fn(cookie) {
          case cookie {
            #(cookie_name, _) if cookie_name == name -> Error(Nil)
            #(name, value) -> Ok(name <> "=" <> value)
          }
        })
        |> string.join("; ")

      Request(..req, headers: [#("cookie", new_cookies_string), ..headers])
    }
    Error(_) -> req
  }
}
