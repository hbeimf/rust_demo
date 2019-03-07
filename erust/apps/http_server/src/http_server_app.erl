%%%-------------------------------------------------------------------
%% @doc http_server public API
%% @end
%%%-------------------------------------------------------------------

-module(http_server_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", cowboy_static, {priv_file, http_server, "index.html"}},
			{"/websocket", ws_handler, []},
			{"/static/[...]", cowboy_static, {priv_dir, http_server, "static"}}
		]}
	]),
	{ok, _} = cowboy:start_http(http, 100, [{port, 8899}],
		[{env, [{dispatch, Dispatch}]}]),

    http_server_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
