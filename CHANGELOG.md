# Changelog

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

- Initial release
