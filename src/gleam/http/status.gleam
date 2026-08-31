/// List of used HTTP status codes.
/// Source: https://www.iana.org/assignments/http-status-codes
import gleam/int

/// A HTTP status code
pub type Code =
  Int

// Informational
// ##############

// [RFC9110, Section 15.2.1]
pub const continue: Code = 100

// [RFC9110, Section 15.2.2]
pub const switching_protocols: Code = 101

// [RFC2518] -- WebDAV
pub const processing: Code = 102

// [RFC8297]
pub const early_hints: Code = 103

// Success
// ########

// [RFC9110, Section 15.3.1]
pub const ok: Code = 200

// [RFC9110, Section 15.3.2]
pub const created: Code = 201

// [RFC9110, Section 15.3.3]
pub const accepted: Code = 202

// [RFC9110, Section 15.3.4]
pub const non_authoritative_information: Code = 203

// [RFC9110, Section 15.3.5]
pub const no_content: Code = 204

// [RFC9110, Section 15.3.6]
pub const reset_content: Code = 205

// [RFC9110, Section 15.3.7]
pub const partial_content: Code = 206

// [RFC4918] -- WebDAV
pub const multistatus: Code = 207

// [RFC5842] -- WebDAV
pub const already_reported: Code = 208

// [RFC3229]
pub const im_used: Code = 226

// Redirection
// ############

// [RFC9110, Section 15.4.1]
pub const multiple_choices: Code = 300

// [RFC9110, Section 15.4.2]
pub const moved_permanently: Code = 301

// [RFC9110, Section 15.4.3]
pub const found: Code = 302

// [RFC9110, Section 15.4.4]
pub const see_other: Code = 303

// [RFC9110, Section 15.4.5]
pub const not_modified: Code = 304

// [RFC9110, Section 15.4.6]
pub const use_proxy: Code = 305

// 306 (unused) [RFC9110, Section 15.4.7]

// [RFC9110, Section 15.4.8]
pub const temporary_redirect: Code = 307

// [RFC9110, Section 15.4.9]
pub const permanent_redirect: Code = 308

// Client Error
// #############

// [RFC9110, Section 15.5.1]
pub const bad_request: Code = 400

// [RFC9110, Section 15.5.2]
pub const unauthorized: Code = 401

// [RFC9110, Section 15.5.3]
pub const payment_required: Code = 402

// [RFC9110, Section 15.5.4]
pub const forbidden: Code = 403

// [RFC9110, Section 15.5.5]
pub const not_found: Code = 404

// [RFC9110, Section 15.5.6]
pub const method_not_allowed: Code = 405

// [RFC9110, Section 15.5.7]
pub const not_acceptable: Code = 406

// [RFC9110, Section 15.5.8]
pub const proxy_authentication_required: Code = 407

// [RFC9110, Section 15.5.9]
pub const request_timeout: Code = 408

// [RFC9110, Section 15.5.10]
pub const conflict: Code = 409

// [RFC9110, Section 15.5.11]
pub const gone: Code = 410

// [RFC9110, Section 15.5.12]
pub const length_required: Code = 411

// [RFC9110, Section 15.5.13]
pub const precondition_failed: Code = 412

// [RFC9110, Section 15.5.14]
pub const content_too_large: Code = 413

// [RFC9110, Section 15.5.15]
pub const uri_too_long: Code = 414

// [RFC9110, Section 15.5.16]
pub const unsupported_media_type: Code = 415

// [RFC9110, Section 15.5.17]
pub const range_not_satisfiable: Code = 416

// [RFC9110, Section 15.5.18]
pub const expectation_failed: Code = 417

// 418 (unused) [RFC9110, Section 15.5.19]

// [RFC9110, Section 15.5.20]
pub const misdirected_request: Code = 421

// [RFC9110, Section 15.5.21]
pub const unprocessable_content: Code = 422

// [RFC4918] -- WebDAV
pub const locked: Code = 423

// [RFC4918] -- WebDAV
pub const failed_dependency: Code = 424

// [RFC8470]
pub const too_early: Code = 425

// [RFC9110, Section 15.5.22]
pub const upgrade_required: Code = 426

// [RFC6585]
pub const precondition_required: Code = 428

// [RFC6585]
pub const too_many_requests: Code = 429

// [RFC6585]
pub const request_header_fields_too_large: Code = 431

// [RFC7725]
pub const unavailable_for_legal_reasons: Code = 451

// Server Error
// #############

// [RFC9110, Section 15.6.1]
pub const internal_server_error: Code = 500

// [RFC9110, Section 15.6.2]
pub const not_implemented: Code = 501

// [RFC9110, Section 15.6.3]
pub const bad_gateway: Code = 502

// [RFC9110, Section 15.6.4]
pub const service_unavailable: Code = 503

// [RFC9110, Section 15.6.5]
pub const gateway_timeout: Code = 504

// [RFC9110, Section 15.6.6]
pub const http_version_not_supported: Code = 505

// [RFC2295]
pub const variant_also_negotiates: Code = 506

// [RFC4918] -- WebDAV
pub const insufficient_storage: Code = 507

// [RFC5842] -- WebDAV
pub const loop_detected: Code = 508

// 510 (obsoleted) [RFC2774][Status change of HTTP experiments to Historic]

// [RFC6585]
pub const network_authentication_required: Code = 511

/// Status code class
pub type Class {
  Informational
  Success
  Redirection
  ClientError
  ServerError
}

/// Abstract a HTTP code to its class
pub fn to_class(code: Code) -> Result(Class, Nil) {
  case code / 100 {
    1 -> Ok(Informational)
    2 -> Ok(Success)
    3 -> Ok(Redirection)
    4 -> Ok(ClientError)
    5 -> Ok(ServerError)
    _ -> Error(Nil)
  }
}

/// Convert a numeric HTTP code to human readable string
pub fn to_string(code: Code) -> String {
  case code {
    100 -> "Continue"
    101 -> "Switching Protocols"
    102 -> "Processing"
    103 -> "Early Hints"

    200 -> "OK"
    201 -> "Created"
    202 -> "Accepted"
    203 -> "Non-Authoritative Information"
    204 -> "No Content"
    205 -> "Reset Content"
    206 -> "Partial Content"
    207 -> "Multi-Status"
    208 -> "Already Reported"
    226 -> "IM Used"

    300 -> "Multiple Choices"
    301 -> "Moved Permanently"
    302 -> "Found"
    303 -> "See Other"
    304 -> "Not Modified"
    305 -> "Use Proxy"
    307 -> "Temporary Redirect"
    308 -> "Permanent Redirect"

    400 -> "Bad Request"
    401 -> "Unauthorized"
    402 -> "Payment Required"
    403 -> "Forbidden"
    404 -> "Not Found"
    405 -> "Method Not Allowed"
    406 -> "Not Acceptable"
    407 -> "Proxy Authentication Required"
    408 -> "Request Timeout"
    409 -> "Conflict"
    410 -> "Gone"
    411 -> "Length Required"
    412 -> "Precondition Failed"
    413 -> "Content Too Large"
    414 -> "URI Too Long"
    415 -> "Unsupported Media Type"
    416 -> "Range Not Satisfiable"
    417 -> "Expectation Failed"
    421 -> "Misdirected Request"
    422 -> "Unprocessable Content"
    423 -> "Locked"
    424 -> "Failed Dependency"
    425 -> "Too Early"
    426 -> "Upgrade Required"
    428 -> "Precondition Required"
    429 -> "Too Many Requests"
    431 -> "Request Header Fields Too Large"
    451 -> "Unavailable For Legal Reasons"

    500 -> "Internal Server Error"
    501 -> "Not Implemented"
    502 -> "Bad Gateway"
    503 -> "Service Unavailable"
    504 -> "Gateway Timeout"
    505 -> "HTTP Version Not Supported"
    506 -> "Variant Also Negotiates"
    507 -> "Insufficient Storage"
    508 -> "Loop Detected"
    511 -> "Network Authentication Required"

    _ -> "[unknown HTTP code: " <> int.to_string(code) <> "]"
  }
}
