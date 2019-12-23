import gleam/string

// HTTP standard method as defined by RFC 2616, and PATCH which is defined by
// RFC 5789.
//
pub type Method {
  Get
  Post
  Head
  Put
  Delete
  Trace
  Connect
  Options
  Patch
}

pub fn parse_method(s) {
  case string.lowercase(s) {
    "connect" -> Ok(Connect)
    "delete" -> Ok(Delete)
    "get" -> Ok(Get)
    "head" -> Ok(Head)
    "options" -> Ok(Options)
    "patch" -> Ok(Patch)
    "post" -> Ok(Post)
    "put" -> Ok(Put)
    "trace" -> Ok(Trace)
    _ -> Error(Nil)
  }
}

pub fn method_to_string(method) {
  case method {
    Connect -> "connect"
    Delete -> "delete"
    Get -> "get"
    Head -> "head"
    Options -> "options"
    Patch -> "patch"
    Post -> "post"
    Put -> "put"
    Trace -> "trace"
  }
}

pub external fn method_from_erlang(anything) -> Result(Method, Nil)
  = "gleam_http_native" "method_from_erlang"
