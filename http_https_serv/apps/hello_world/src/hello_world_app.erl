%%%-------------------------------------------------------------------
%% @doc hello_world public API
%% @end
%%%-------------------------------------------------------------------

-module(hello_world_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/", toppage_handler, []}
		]}
	]),
	PrivDir = code:priv_dir(hello_world),
	_R = cowboy:start_https(https, 100, [
		{port, 8443},
		{cacertfile, PrivDir ++ "/ssl/cowboy-ca.crt"},
		{certfile, PrivDir ++ "/ssl/server.crt"},
		{keyfile, PrivDir ++ "/ssl/server.key"}
	], [{env, [{dispatch, Dispatch}]}]),

	hello_world_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
