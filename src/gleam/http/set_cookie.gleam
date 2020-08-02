pub type SameSitePolicy{
    Lax
    Strict
    None
}

pub type Options {
    Domain(String)
    MaxAge(Int)
    Path(String)
    HttpOnly
    Secure
    SameSite(SameSitePolicy)
}


// // Plug sets secure true automatically if request/conn is https
// // https://github.com/elixir-plug/plug/blob/v1.10.3/lib/plug/conn.ex#L1464
//
//
// pub type Cookie{
//     Cookie(key: String, value: String)
// }
//
// pub type CookieOption{
//     Path(path: String)
//     HttpOnly
// }
//
//
// // takes ";"
// fn parse_cookie_list() {
//     todo
// }
//
// // does set cookie multiple with comma work
// fn parse_cookie() {
//     todo
// }
//
// fn set_resp_cookie(cookie: C, options) {
//     todo
//     // Set new header
// }
//
// fn set_req_cookies(cookie: Cookie) {
// // Join request header
// }
//
// fn get_req_cookies()
//
// fn get_resp_cookies() {
//
// }
// Session pull value and secure on the request
