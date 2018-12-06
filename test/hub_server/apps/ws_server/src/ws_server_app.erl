%%%-------------------------------------------------------------------
%% @doc ws_server public API
%% @end
%%%-------------------------------------------------------------------

-module(ws_server_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			% {"/", cowboy_static, {priv_file, websocket_chat_demo, "index.html"}},
			{"/", ws_handler, []},
			{"/report", handler_gs_report, []},
			{"/ws", ws_handler_game_server, []},
			{"/websocket", ws_handler_gateway, []}
			
			% {"/static/[...]", cowboy_static, {priv_dir, websocket_chat_demo, "static"}}
		]}
	]),

	{ok, ConfigList} = sys_config:get_config(http),
	% {_, {host, Host}, _} = lists:keytake(host, 1, ConfigList),
	{_, {port, Port}, _} = lists:keytake(port, 1, ConfigList),


	{ok, _} = cowboy:start_http(http, 100, [{port, Port}],
		[{env, [{dispatch, Dispatch}]}]),
    ws_server_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
