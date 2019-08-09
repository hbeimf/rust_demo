%%%-------------------------------------------------------------------
%% @doc mysqlc public API
%% @end
%%%-------------------------------------------------------------------

-module(mysqlc_app).
-include_lib("glib/include/log.hrl").
-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	init_pool(),
    mysqlc_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
init_pool() ->
	% ?LOG("init pool"),
	Root = glib:root_dir(),
	PoolConfigDir = lists:concat([Root, "db_pool.config"]),
	?LOG({"init pool", Root, PoolConfigDir}),
	{ok, [PoolConfigList|_]} = file:consult(PoolConfigDir),
	% ?LOG(PoolConfigList),
	
	mysqlc_comm:start_pools(PoolConfigList),
	
	ok.