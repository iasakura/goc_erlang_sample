%%%-------------------------------------------------------------------
%% @doc goc_erlang_sample public API
%% @end
%%%-------------------------------------------------------------------

-module(goc_erlang_sample_app).

-behaviour(application).

-import(goc_erlang, [eval/1, c/1, app/2, minus/2]).

-export([start/2, stop/1]).

% -include_lib("goc_erlang/src/petri_structure/petri_structure.hrl").

% start(_StartType, _StartArgs) ->
%     goc_erlang_sample_sup:start_link(),
%     P = eval(minus(c(3), c(5))),
%     P ! {self(), {turnstile, right, q}, #token{estack = [], domain = q}},
%     Loop = fun Loop() ->
%         receive
%             {P, {turnstile, right, a}, {ok, #token{estack = [], domain = V}}} ->
%                 io:format("a: ~p~n", [V]);
%             V ->
%                 io:format("???: ~p~n", [V]),
%                 Loop()
%         end
%     end,
%     Loop().

% stop(_State) ->
%     ok.

% %% internal functions

start(_Type, _Args) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/websocket", ws_h, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, 8080}], #{
        env => #{dispatch => Dispatch}
    }),
    goc_erlang_sample_sup:start_link().

stop(_State) ->
    ok = cowboy:stop_listener(http).
