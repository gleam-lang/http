import gleam/int
import gleam/list
import gleam/option.{Option, Some}
import gleam/string

const epoch = "Expires=Thu, 01 Jan 1970 00:00:00 GMT"

/// Policy options for the SameSite cookie attribute
///
/// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie/SameSite
pub type SameSitePolicy {
  Lax
  Strict
  None
}

/// Attributes of a cookie when sent to a client in the `set-cookie` header.
pub type Attributes {
  Attributes(
    max_age: Option(Int),
    domain: Option(String),
    path: Option(String),
    secure: Bool,
    http_only: Bool,
    same_site: Option(SameSitePolicy),
  )
}

/// Helper to create empty `Attributes` for a cookie.
pub fn empty_attributes() {
  Attributes(
    max_age: option.None,
    domain: option.None,
    path: option.None,
    secure: False,
    http_only: False,
    same_site: option.None,
  )
}

/// Helper to create sensible default attributes for a set cookie.
///
/// NOTE these defaults ensure you cookie is always available to you application.
/// However this is not a fully secure solution.
/// You should consider setting a Secure and/or SameSite attribute.
///
/// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#Attributes
pub fn default_attributes() {
  Attributes(
    max_age: option.None,
    domain: option.None,
    path: Some("/"),
    secure: False,
    http_only: True,
    same_site: option.None,
  )
}

fn same_site_to_string(policy) {
  case policy {
    Lax -> "Lax"
    Strict -> "Strict"
    None -> "None"
  }
}

/// Update the MaxAge of a set of attributes to 0.
/// This informes the client that the cookie should be expired.
pub fn expire_attributes(attributes) {
  let Attributes(
    max_age: _max_age,
    domain: domain,
    path: path,
    secure: secure,
    http_only: http_only,
    same_site: same_site,
  ) = attributes
  Attributes(
    max_age: Some(0),
    domain: domain,
    path: path,
    secure: secure,
    http_only: http_only,
    same_site: same_site,
  )
}

fn attributes_to_list(attributes) {
  let Attributes(
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
    option.map(max_age, fn(max_age) { ["MaxAge=", int.to_string(max_age)] }),
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

/// Serialize a cookie and attributes.
///
/// This is the serialization of a cookie for the `set-cookie` header
pub fn set_cookie_string(name, value, attributes) {
  [[name, "=", value], ..attributes_to_list(attributes)]
  |> list.map(string.join(_, ""))
  |> string.join("; ")
}
