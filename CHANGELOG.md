# Changelog

## v1.1.0 - unreleased

- The `gleam/http` module gains the `Scheme`, `Service`, `Request`, and
  `Response` types, along with associated functions `scheme_to_string`,
  `scheme_from_string`, `req_uri`, `response`, `req_segments`, `req_query`,
  `req_header`, `resp_header`, `prepend_req_header`,
  `prepend_response_header`, `set_resp_body`, `map_response_body`,
  `try_map_response_body`, and `redirect`.
- Created the `gleam/http/middleware` module with the `Middleware` type and
  the `map_response_body` type.

## v1.0.0 - 2020-06-30

- Initial release
