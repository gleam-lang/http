# Changelog

## v3.4.0 - 2023-08-02

- The `gleam/http` module gains the `parse_multipart_headers`,
  `parse_multipart_body`, and `parse_content_disposition` functions.

## v3.3.0 - 2023-07-29

- Updated for Gleam v0.30.0.

## v3.2.0 - 2023-04-21

- The `gleam/http/request` module gains the `to` function for creating requests.

## v3.1.2 - 2023-03-02

- Updated for Gleam v0.27.0.

## v3.1.1 - 2022-10-15

- Fixed a bug where the `request.set_header` function would lowercase the value
  rather than the key.

## v3.1.0 - 2022-08-05

- Added `set_header` to `request` and `response`.

## v3.0.1 - 2022-05-15

- Fixed some warnings from unused imports.

## v3.0.0 - 2022-01-29

- Updated for Gleam v0.19.0. As a result the `method_from_dynamic` function now
  returns a list of decode errors.
- The default cookie attributes now includes `SameSite=Lax`.
- The `request`, `response` and `cookie` modules have been extracted from the
  `http` module.

## v2.1.0 - 2021-11-26

- Converted to use the Gleam build tool.

## v2.0.2 - 2021-09-19

- Updated for Gleam stdlib v0.17.1.
- Updated to work for Gleam JS.

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
