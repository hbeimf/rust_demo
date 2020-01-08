%%%-------------------------------------------------------------------
%% @doc wss_common public API
%% @end
%%%-------------------------------------------------------------------

-module(wss_common_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    start_ws_server(),
    wss_common_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

start_ws_server() ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/ws", wss_common_handler, []}
        ]}
    ]),

    {ok, ConfigList} = sys_config:get_config(http),
    % {_, {host, Host}, _} = lists:keytake(host, 1, ConfigList),
    {_, {port, Port}, _} = lists:keytake(port, 1, ConfigList),


    {ok, _} = cowboy:start_http(http, 100, [{port, Port}, {max_connections, 1000000}],
        [{env, [{dispatch, Dispatch}]}]),
    ok.