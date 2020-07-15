# Changelog

## v1.1.0 - unreleased

- The `gleam/http` module gains the `Scheme`, `Service`, `Request`, and
  `Response` types, along with associated functions `scheme_to_string`,
  `scheme_from_string`, `req_uri`, `response`, `req_segments`, `get_query`,
  `get_req_header`, `get_resp_header`, `prepend_req_header`, `seq_req_host`,
  `set_req_path`, `prepend_resp_header`, `set_method`, `set_req_body`,
  `set_resp_body`, `map_resp_body`, `map_req_body` `try_map_resp_body`,
  `set_query`, `req_from_uri`, `default_req`, and `redirect`.
- Created the `gleam/http/middleware` module with the `Middleware` type and
  the `method_override`, `prepend_resp_header`, `map_resp_body` middleware
  functions.

## v1.0.0 - 2020-06-30

- Initial release
