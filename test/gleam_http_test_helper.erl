-module(gleam_http_test_helper).

-export([atom/1]).

atom(String) ->
    binary_to_atom(String).
