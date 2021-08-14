# Changelog

## v2.0.1 - 2021-08-14

- Upgraded for Gleam v0.16.

## v2.0.0 - 2021-02-22

- The `gleam/http.get_req_origin` function returns a `Result(String, Nil)`
  instead of an `Option(String)`.
- Gleam v0.14 support.

## v1.7.0 - 2020-11-29

- The `gleam/http` module gains the `get_resp_cookies` function.
- The `gleam/http.get_resp_cookie` function as been deprecated in favour of
  `gleam/http.get_resp_cookie`.

## v1.6.0 - 2020-11-19

- The `gleam/http.default_req` function returns a `Request(String)` again,
  reverting the change from v1.5.0.
- The `gleam/http` module gains the `get_resp_cookie`, `set_scheme` and
  `set_port` functions.
- The Gleam stdlib version requirement has been relaxed.

## v1.5.0 - 2020-09-23

- The `gleam/http` module gains the `get_req_origin` function.
- Fix bug to correctly set cookie `Max-Age` attribute
- The `gleam/http.default_req` function returns a `Request(BitString)` instead
  `Request(String)`

## v1.3.0 - 2020-08-04

- The `gleam/http/cookie` module has been merged into the `gleam/http` module.

## v1.2.0 - 2020-08-04

- The `gleam/http` module gains the `get_req_cookies`, `set_req_cookie`
  `set_resp_cookie` and `expire_resp_cookie` functions.
- Created the `gleam/http/cookie` module with `SameSitePolicy` and `Attributes`
  types, along with associated functions `empty_attributes`,
  `default_attributes`, `expire_attributes` and `set_cookie_string`.

## v1.1.1 - 2020-07-21

- Relax dependency requirements on stdlib

## v1.1.0 - 2020-07-19

- The `gleam/http` module gains the `Scheme`, `Service`, `Request`, and
  `Response` types, along with associated functions `scheme_to_string`,
  `scheme_from_string`, `req_uri`, `response`, `path_segments`, `get_query`,
  `get_req_header`, `get_resp_header`, `prepend_req_header`, `seq_host`,
  `set_path`, `prepend_resp_header`, `set_method`, `set_body`, `set_query`,
  `req_from_uri`, `default_req`, and `redirect`. `set_resp_body`,
  `map_resp_body`, `map_req_body` `try_map_resp_body`,
- Created the `gleam/http/middleware` module with the `Middleware` type and
  the `method_override`, `prepend_resp_header`, `map_resp_body` middleware
  functions.

## v1.0.0 - 2020-06-30

- Initial release.
