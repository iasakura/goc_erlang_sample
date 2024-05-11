-module(ws_h).

-import(goc_erlang, [eval/1, c/1, app/2, minus/2]).

-export([init/2]).
-export([websocket_init/1]).
-export([websocket_handle/2]).
-export([websocket_info/2]).

-include_lib("goc_erlang/src/petri_structure/petri_structure.hrl").

f() ->
    P = eval(minus(c(3), c(5))),
    P ! {self(), {turnstile, right, q}, #token{estack = [], domain = q}},
    Loop = fun Loop() ->
        receive
            {P, {turnstile, right, a}, {ok, #token{estack = [], domain = V}}} ->
                io:format("a: ~p~n", [V]);
            V ->
                io:format("???: ~p~n", [V]),
                Loop()
        end
    end,
    Loop().

init(Req, Opts) ->
    {cowboy_websocket, Req, Opts}.

decode_head(<<A>>) -> binary_to_atom(A).

decode_address(<<A>>) ->
    decode_head(A);
decode_address([<<"variable">>, <<S>>, A]) ->
    {decode_head(A), binary_to_list(S), decode_address(A)};
decode_address([<<A>>, <<LR>>, A]) ->
    {decode_head(A), decode_head(LR), decode_address(A)};
decode_address(A) ->
    erlang:error("Cannot decode address", A).

decode_token(#{estack := ES, domain := D}) -> erlang:error("TODO").

websocket_handle({text, Msg}, State) ->
    #{address := JSONAddress, token := JSONToken} = jsone:decode(Msg),
    A = decode_address(JSONAddress),
    T = decode_token(JSONToken),
    State ! {self(), A, T},
    {[], State};
websocket_handle(_Data, State) ->
    {[], State}.

websocket_info({State, Address, Token}, State) ->
    {
        [
            {text, jsone:encode([{<<"address">>, Address}, {<<"token">>, Token}])}
        ],
        State
    };
websocket_info(_Info, State) ->
    {[], State}.
