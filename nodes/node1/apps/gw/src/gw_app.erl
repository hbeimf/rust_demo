%%%-------------------------------------------------------------------
%% @doc gw public API
%% @end
%%%-------------------------------------------------------------------

-module(gw_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    start_gw_server(),
    gw_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
start_gw_server() ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/ws", gw_handler, []}
        ]}
    ]),

    {ok, ConfigList} = sys_config:get_config(http),
    % {_, {host, Host}, _} = lists:keytake(host, 1, ConfigList),
    {_, {port, Port}, _} = lists:keytake(port, 1, ConfigList),


    {ok, _} = cowboy:start_http(http, 100, [{port, Port}, {max_connections, 1000000}],
        [{env, [{dispatch, Dispatch}]}]),
    ok.