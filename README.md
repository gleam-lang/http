# Gleam HTTP

Types and functions for HTTP clients and servers!

## Server adapters

Server adapters can be used to run Gleam HTTP services written using this
package. Here's a full list of the servers and adapters available, sorted
alphabetically.

| Adapter                        | About                                                          |
| ---                            | ---                                                            |
| [cgi][cgi]                     | [Cgi][cgi] is a adapter for the Common Gateway Interface.      |
| [fcgi][fcgi]                   | [Cgi][cgi] is a adapter for the Fast Common Gateway Interface. |
| [ewe][ewe]                     | [Ewe][ewe] is a Gleam HTTP2 & HTTP1.1 web server               |
| [gleam_cowboy][cowboy-adapter] | [Cowboy][cowboy] is an Erlang HTTP2 & HTTP1.1 web server       |
| [gleam_elli][elli-adapter]     | [Elli][elli] is an Erlang HTTP1.1 web server                   |
| [mist][mist]                   | [Mist][mist] is a Gleam HTTP1.1 server                         |

[cgi]: https://github.com/lpil/cgi
[cowboy-adapter]: https://github.com/gleam-lang/cowboy
[cowboy]:https://github.com/ninenines/cowboy
[elli-adapter]: https://github.com/gleam-lang/elli
[elli]:https://github.com/elli-lib/elli
[ewe]:https://github.com/vshakitskiy/ewe
[fcgi]: https://github.com/jtdowney/fcgi
[mist]: https://github.com/rawhat/mist
[plug]:https://github.com/elixir-plug/plug

## Client adapters

Client adapters are used to send HTTP requests to services over the network.
Here's a full list of the client adapters available, sorted alphabetically.

| Adapter                          | About                                                    |
| ---                              | ---                                                      |
| [gleam_fetch][fetch-adapter]     | [fetch][fetch] is a HTTP client included with JavaScript |
| [gleam_hackney][hackney-adapter] | [Hackney][hackney] is a simple HTTP client for Erlang    |
| [gleam_httpc][httpc-adapter]     | [httpc][httpc] is a HTTP client included with Erlang     |

[hackney]: https://github.com/benoitc/hackney
[hackney-adapter]: https://github.com/gleam-lang/hackney
[httpc]: https://erlang.org/doc/man/httpc.html
[httpc-adapter]: https://github.com/gleam-lang/httpc
[fetch]: https://developer.mozilla.org/en-US/docs/Web/API/Fetch_API
[fetch-adapter]: https://github.com/gleam-lang/fetch
