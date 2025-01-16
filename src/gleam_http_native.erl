-module(gleam_http_native).
-export([decode_method/1, is_valid_tchar/1]).

is_valid_tchar(X) when is_integer(X) ->
    case X of
        $! -> true;
        $# -> true;
        $$ -> true;
        $% -> true;
        $& -> true;
        $' -> true;
        $* -> true;
        $+ -> true;
        $- -> true;
        $. -> true;
        $^ -> true;
        $_ -> true;
        $` -> true;
        $| -> true;
        $~ -> true;
        % DIGIT
        _ when X >= 16#30 andalso X =< 16#39 -> true;
        % ALPHA
        _ when (X >= 16#41 andalso X =< 16#5A) orelse (X >= 16#61 andalso X =< 16#7A) -> true;
        _ -> false
    end;
is_valid_tchar(_) -> false.

is_valid_token([]) -> false;
is_valid_token(<<>>) -> false;
is_valid_token(X) when is_list(X) orelse is_bitstring(X) -> do_is_valid_token(X, true);
is_valid_token(_) -> false.

do_is_valid_token(_, false) -> false;
do_is_valid_token([H|T] = X, true) when is_list(X) -> do_is_valid_token(T, is_valid_tchar(H));
do_is_valid_token(<<H, T/bits>> = X, true) when is_bitstring(X) -> do_is_valid_token(T, is_valid_tchar(H));
do_is_valid_token(_, X) -> X.

normalise_method(X) when is_bitstring(X) -> {ok, {other, X}};
normalise_method(X) when is_list(X) -> {ok, {other, list_to_binary(X)}};
normalise_method(_) -> {error, nil}.

decode_method(Term) ->
    case Term of
        "CONNECT"     -> {ok, connect};
        "DELETE"      -> {ok, delete};
        "GET"         -> {ok, get};
        "HEAD"        -> {ok, head};
        "OPTIONS"     -> {ok, options};
        "PATCH"       -> {ok, patch};
        "POST"        -> {ok, post};
        "PUT"         -> {ok, put};
        "TRACE"       -> {ok, trace};
        'CONNECT'     -> {ok, connect};
        'DELETE'      -> {ok, delete};
        'GET'         -> {ok, get};
        'HEAD'        -> {ok, head};
        'OPTIONS'     -> {ok, options};
        'PATCH'       -> {ok, patch};
        'POST'        -> {ok, post};
        'PUT'         -> {ok, put};
        'TRACE'       -> {ok, trace};
        <<"CONNECT">> -> {ok, connect};
        <<"DELETE">>  -> {ok, delete};
        <<"GET">>     -> {ok, get};
        <<"HEAD">>    -> {ok, head};
        <<"OPTIONS">> -> {ok, options};
        <<"PATCH">>   -> {ok, patch};
        <<"POST">>    -> {ok, post};
        <<"PUT">>     -> {ok, put};
        <<"TRACE">>   -> {ok, trace};
        X             ->
            case is_valid_token(X) of
                true -> normalise_method(X);
                false -> {error, nil}
            end
    end.
