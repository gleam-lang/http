import gleam/int
import gleam/list
import gleam/option.{Option, Some}
import gleam/string

const epoch = "aa"

pub type SameSitePolicy {
  Lax
  Strict
  None
}

pub type Attributes {
  Attributes(
    max_age: Option(Int),
    domain: Option(String),
    path: Option(String),
    secure: Bool,
    http_only: Bool,
    // TODO I don't think it needs Option
    same_site: Option(SameSitePolicy),
  )
}

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
      Some(0) -> Some(["Expires=Thu, 01 Jan 1970 00:00:00 GMT"])
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

pub fn set_cookie_string(key, value, attributes) {
  [[key, "=", value], ..attributes_to_list(attributes)]
  |> list.map(string.join(_, ""))
  |> string.join("; ")
}
