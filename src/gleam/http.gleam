// HTTP standard method as defined by RFC 2616, and PATCH which is defined by
// RFC 5789.
//
pub enum Method =
  | Get
  | Post
  | Head
  | Put
  | Delete
  | Trace
  | Connect
  | Options
  | Patch

pub fn parse_method(s) {
  case s {
  | "Connect" -> Ok(Connect)
  | "CONNECT" -> Ok(Connect)
  | "connect" -> Ok(Connect)
  | "Delete" -> Ok(Delete)
  | "DELETE" -> Ok(Delete)
  | "delete" -> Ok(Delete)
  | "Get" -> Ok(Get)
  | "GET" -> Ok(Get)
  | "get" -> Ok(Get)
  | "Head" -> Ok(Head)
  | "HEAD" -> Ok(Head)
  | "head" -> Ok(Head)
  | "Options" -> Ok(Options)
  | "OPTIONS" -> Ok(Options)
  | "options" -> Ok(Options)
  | "Patch" -> Ok(Patch)
  | "PATCH" -> Ok(Patch)
  | "patch" -> Ok(Patch)
  | "Post" -> Ok(Post)
  | "POST" -> Ok(Post)
  | "post" -> Ok(Post)
  | "Put" -> Ok(Put)
  | "PUT" -> Ok(Put)
  | "put" -> Ok(Put)
  | "Trace" -> Ok(Trace)
  | "TRACE" -> Ok(Trace)
  | "trace" -> Ok(Trace)
  | _ -> Error(Nil)
  }
}
