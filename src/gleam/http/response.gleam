import gleam/http.{type Header}
import gleam/http/cookie
import gleam/list
import gleam/option
import gleam/result
import gleam/string

/// A HTTP response.
///
/// The body of the request is parameterised. The HTTP server or client you are
/// using will have a particular set of types it supports for the body.
///
pub type Response(body) {
  Response(
    status: Int,
    /// The request headers. The keys must always be lowercase.
    headers: List(Header),
    body: body,
  )
}

/// Update the body of a response using a given result returning function.
///
/// If the given function returns an `Ok` value the body is set, if it returns
/// an `Error` value then the error is returned.
///
pub fn try_map(
  response: Response(old_body),
  transform: fn(old_body) -> Result(new_body, error),
) -> Result(Response(new_body), error) {
  use body <- result.try(transform(response.body))
  Ok(set_body(response, body))
}

/// Construct an empty Response.
///
/// The body type of the returned response is `String` and could be set with a
/// call to `set_body`.
///
pub fn new(status: Int) -> Response(String) {
  Response(status: status, headers: [], body: "")
}

/// Get the value for a given header.
///
/// If the response does not have that header then `Error(Nil)` is returned.
///
pub fn get_header(response: Response(body), key: String) -> Result(String, Nil) {
  list.key_find(response.headers, string.lowercase(key))
}

/// Set the header with the given value under the given header key.
///
/// If the response already has that key, it is replaced.
///
/// Header keys are always lowercase in `gleam_http`. To use any uppercase
/// letter is invalid.
///
pub fn set_header(
  response: Response(body),
  key: String,
  value: String,
) -> Response(body) {
  let headers = list.key_set(response.headers, string.lowercase(key), value)
  Response(..response, headers: headers)
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
  response: Response(body),
  key: String,
  value: String,
) -> Response(body) {
  let headers = [#(string.lowercase(key), value), ..response.headers]
  Response(..response, headers: headers)
}

/// Set the body of the response, overwriting any existing body.
///
pub fn set_body(
  response: Response(old_body),
  body: new_body,
) -> Response(new_body) {
  let Response(status: status, headers: headers, ..) = response
  Response(status: status, headers: headers, body: body)
}

/// Update the body of a response using a given function.
///
pub fn map(
  response: Response(old_body),
  transform: fn(old_body) -> new_body,
) -> Response(new_body) {
  response.body
  |> transform
  |> set_body(response, _)
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

/// Fetch the cookies sent in a response.
///
/// Badly formed cookies will be discarded.
///
pub fn get_cookies(resp) -> List(#(String, String)) {
  let Response(headers: headers, ..) = resp
  headers
  |> list.filter_map(fn(header) {
    let #(name, value) = header
    case name {
      "set-cookie" -> Ok(cookie.parse(value))
      _ -> Error(Nil)
    }
  })
  |> list.flatten()
}

/// Set a cookie value for a client
///
pub fn set_cookie(
  response: Response(t),
  name: String,
  value: String,
  attributes: cookie.Attributes,
) -> Response(t) {
  prepend_header(
    response,
    "set-cookie",
    cookie.set_header(name, value, attributes),
  )
}

/// Expire a cookie value for a client
///
/// Note: The attributes value should be the same as when the response cookie was set.
pub fn expire_cookie(
  response: Response(t),
  name: String,
  attributes: cookie.Attributes,
) -> Response(t) {
  let attrs = cookie.Attributes(..attributes, max_age: option.Some(0))
  set_cookie(response, name, "", attrs)
}
