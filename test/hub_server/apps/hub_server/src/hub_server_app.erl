%%%-------------------------------------------------------------------
%% @doc hub_server public API
%% @end
%%%-------------------------------------------------------------------

-module(hub_server_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	{_Ip, Port} = rconf:read_config(hub_server),
	{ok, _} = ranch:start_listener(hub_server, 10, ranch_tcp, [{port, Port}], tcp_handler, []),
    hub_server_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
