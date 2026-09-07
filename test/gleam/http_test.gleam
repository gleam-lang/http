import gleam/http
import gleam/uri

pub fn parse_method_test() {
  assert http.parse_method("Connect") == Ok(http.Other("Connect"))

  assert http.parse_method("CONNECT") == Ok(http.Connect)

  assert http.parse_method("connect") == Ok(http.Other("connect"))

  assert http.parse_method("Delete") == Ok(http.Other("Delete"))

  assert http.parse_method("DELETE") == Ok(http.Delete)

  assert http.parse_method("delete") == Ok(http.Other("delete"))

  assert http.parse_method("Get") == Ok(http.Other("Get"))

  assert http.parse_method("GET") == Ok(http.Get)

  assert http.parse_method("get") == Ok(http.Other("get"))

  assert http.parse_method("Head") == Ok(http.Other("Head"))

  assert http.parse_method("HEAD") == Ok(http.Head)

  assert http.parse_method("head") == Ok(http.Other("head"))

  assert http.parse_method("Options") == Ok(http.Other("Options"))

  assert http.parse_method("OPTIONS") == Ok(http.Options)

  assert http.parse_method("options") == Ok(http.Other("options"))

  assert http.parse_method("Patch") == Ok(http.Other("Patch"))

  assert http.parse_method("PATCH") == Ok(http.Patch)

  assert http.parse_method("patch") == Ok(http.Other("patch"))

  assert http.parse_method("Post") == Ok(http.Other("Post"))

  assert http.parse_method("POST") == Ok(http.Post)

  assert http.parse_method("post") == Ok(http.Other("post"))

  assert http.parse_method("Put") == Ok(http.Other("Put"))

  assert http.parse_method("PUT") == Ok(http.Put)

  assert http.parse_method("put") == Ok(http.Other("put"))

  assert http.parse_method("Trace") == Ok(http.Other("Trace"))

  assert http.parse_method("TRACE") == Ok(http.Trace)

  assert http.parse_method("trace") == Ok(http.Other("trace"))

  assert http.parse_method("thingy") == Ok(http.Other("thingy"))

  assert http.parse_method("!#$%&'*+-.^_`|~abcABC123")
    == Ok(http.Other("!#$%&'*+-.^_`|~abcABC123"))

  assert http.parse_method("In-valid method") == Error(Nil)
}

pub fn method_to_string_test() {
  assert http.method_to_string(http.Connect) == "CONNECT"

  assert http.method_to_string(http.Delete) == "DELETE"

  assert http.method_to_string(http.Get) == "GET"

  assert http.method_to_string(http.Head) == "HEAD"

  assert http.method_to_string(http.Options) == "OPTIONS"

  assert http.method_to_string(http.Patch) == "PATCH"

  assert http.method_to_string(http.Post) == "POST"

  assert http.method_to_string(http.Put) == "PUT"

  assert http.method_to_string(http.Trace) == "TRACE"

  assert http.method_to_string(http.Other("ok")) == "ok"

  assert http.method_to_string(http.Other("nope")) == "nope"
}

pub fn scheme_to_string_test() {
  assert http.scheme_to_string(http.Http) == "http"

  assert http.scheme_to_string(http.Https) == "https"
}

pub fn scheme_from_string_test() {
  assert http.scheme_from_string("http") == Ok(http.Http)

  assert http.scheme_from_string("https") == Ok(http.Https)

  assert http.scheme_from_string("ftp") == Error(Nil)
}

pub fn parse_content_disposition_1_test() {
  assert http.parse_content_disposition("inline")
    == Ok(http.ContentDisposition("inline", []))

  assert http.parse_content_disposition("attachment")
    == Ok(http.ContentDisposition("attachment", []))

  assert http.parse_content_disposition(
      "attachment; filename=genome.jpeg; modification-date=\"Wed, 12 Feb 1997 16:29:51 -0500\";",
    )
    == Ok(
      http.ContentDisposition("attachment", [
        #("filename", "genome.jpeg"),
        #("modification-date", "Wed, 12 Feb 1997 16:29:51 -0500"),
      ]),
    )

  assert http.parse_content_disposition("form-data; name=\"user\"")
    == Ok(http.ContentDisposition("form-data", [#("name", "user")]))

  assert http.parse_content_disposition("form-data; NAME=\"submit-name\"")
    == Ok(http.ContentDisposition("form-data", [#("name", "submit-name")]))

  assert http.parse_content_disposition(
      "form-data; name=\"files\"; filename=\"file1.txt\"",
    )
    == Ok(
      http.ContentDisposition("form-data", [
        #("name", "files"),
        #("filename", "file1.txt"),
      ]),
    )

  assert http.parse_content_disposition("file; filename=\"file1.txt\"")
    == Ok(http.ContentDisposition("file", [#("filename", "file1.txt")]))

  assert http.parse_content_disposition("file; filename=\"file2.gif\"")
    == Ok(http.ContentDisposition("file", [#("filename", "file2.gif")]))

  assert http.parse_content_disposition("file; filename=\"file2\\\".gif\"")
    == Ok(http.ContentDisposition("file", [#("filename", "file2\".gif")]))

  assert http.parse_content_disposition("file; filename=\"file2") == Error(Nil)
}

pub fn parse_link_header_test() {
  let assert Ok(uri1) = uri.parse("https://example.com/page2")
  let assert Ok(uri2) = uri.parse("https://example.com")

  assert http.parse_link_header("<https://example.com/page2>; rel=\"next\"")
    == Ok([http.LinkHeader(uri1, [#("rel", "next")])])

  assert http.parse_link_header(
      "<https://example.com/page2>; rel=\"next\"; title=\"next chapter\"",
    )
    == Ok([
      http.LinkHeader(uri1, [
        #("rel", "next"),
        #("title", "next chapter"),
      ]),
    ])

  assert http.parse_link_header("<https://example.com>; REL=\"next\"")
    == Ok([http.LinkHeader(uri2, [#("rel", "next")])])

  assert http.parse_link_header("<https://example.com>; rel=next")
    == Ok([http.LinkHeader(uri2, [#("rel", "next")])])

  assert http.parse_link_header(
      "<https://example.com>; title=foo; rel=\"next\"",
    )
    == Ok([http.LinkHeader(uri2, [#("title", "foo"), #("rel", "next")])])

  assert http.parse_link_header("<https://example.com>")
    == Ok([http.LinkHeader(uri2, [])])

  assert http.parse_link_header("<https://example.com>; rel=\"next\"; anchor")
    == Ok([
      http.LinkHeader(uri2, [#("rel", "next"), #("anchor", "")]),
    ])

  assert http.parse_link_header("<https://example.com>; rel = \"next\"")
    == Ok([http.LinkHeader(uri2, [#("rel", "next")])])

  assert http.parse_link_header(
      "<https://example.com>; rel=\"next\"; rel=\"prev\"",
    )
    == Ok([
      http.LinkHeader(uri2, [#("rel", "next"), #("rel", "prev")]),
    ])

  assert http.parse_link_header("") == Ok([])
}

pub fn parse_link_header_multiple_links_test() {
  let assert Ok(uri1) = uri.parse("https://example.com/page1")
  let assert Ok(uri2) = uri.parse("https://example.com/page3")
  assert http.parse_link_header(
      "<https://example.com/page1>; rel=\"prev\", <https://example.com/page3>; rel=\"next\"",
    )
    == Ok([
      http.LinkHeader(uri1, [#("rel", "prev")]),
      http.LinkHeader(uri2, [#("rel", "next")]),
    ])

  let assert Ok(uri3) = uri.parse("/TheBook/chapter2")
  let assert Ok(uri4) = uri.parse("/TheBook/chapter4")
  assert http.parse_link_header(
      "</TheBook/chapter2>; rel=\"previous\"; title*=UTF-8'de'letztes%20Kapitel, </TheBook/chapter4>; rel=\"next\"; title*=UTF-8'de'n%c3%a4chstes%20Kapitel",
    )
    == Ok([
      http.LinkHeader(uri3, [
        #("rel", "previous"),
        #("title*", "UTF-8'de'letztes%20Kapitel"),
      ]),
      http.LinkHeader(uri4, [
        #("rel", "next"),
        #("title*", "UTF-8'de'n%c3%a4chstes%20Kapitel"),
      ]),
    ])
}

pub fn parse_link_header_quoting_test() {
  let assert Ok(uri1) = uri.parse("https://example.com/page2")
  let assert Ok(uri2) = uri.parse("https://example.com/page1")
  assert http.parse_link_header(
      "<https://example.com/page2>; rel=\"next\"; title=\"page, two\", <https://example.com/page1>; rel=\"prev\"",
    )
    == Ok([
      http.LinkHeader(uri1, [#("rel", "next"), #("title", "page, two")]),
      http.LinkHeader(uri2, [#("rel", "prev")]),
    ])

  assert http.parse_link_header(
      "<https://example.com/page2>; rel=\"next\"; title=\"say \\\"hello\\\"\"",
    )
    == Ok([
      http.LinkHeader(uri1, [
        #("rel", "next"),
        #("title", "say \"hello\""),
      ]),
    ])
}

pub fn parse_link_header_empty_elements_test() {
  let assert Ok(uri1) = uri.parse("https://example.com")
  let assert Ok(uri2) = uri.parse("https://a.com")
  let assert Ok(uri3) = uri.parse("https://b.com")

  assert http.parse_link_header(", <https://example.com>; rel=\"next\"")
    == Ok([http.LinkHeader(uri1, [#("rel", "next")])])

  assert http.parse_link_header(
      "<https://a.com>; rel=\"prev\", , <https://b.com>; rel=\"next\"",
    )
    == Ok([
      http.LinkHeader(uri2, [#("rel", "prev")]),
      http.LinkHeader(uri3, [#("rel", "next")]),
    ])

  assert http.parse_link_header("<https://example.com>; rel=\"next\",")
    == Ok([http.LinkHeader(uri1, [#("rel", "next")])])
}

pub fn parse_link_header_error_test() {
  assert http.parse_link_header("https://example.com; rel=\"next\"")
    == Error(Nil)

  assert http.parse_link_header("garbage<https://example.com>; rel=\"next\"")
    == Error(Nil)

  assert http.parse_link_header("<https://example.com>; rel=") == Error(Nil)

  assert http.parse_link_header("<https://example.com> rel=\"next\"")
    == Error(Nil)

  assert http.parse_link_header(
      "<https://example.com>; rel=\"next\" title=\"foo\"",
    )
    == Error(Nil)

  assert http.parse_link_header("<https://example.com>;") == Error(Nil)

  assert http.parse_link_header("<https://example.com>;  ") == Error(Nil)
}
