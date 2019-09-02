% mysqlc_pool.erl
% demo.erl
-module(mysqlc_pool).

-include_lib("glib/include/log.hrl").
-compile(export_all).


init_pool() ->
	% ?LOG("init pool"),
	Root = glib:root_dir(),
	PoolConfigDir = lists:concat([Root, "db_pool.config"]),
	?LOG({"init pool", Root, PoolConfigDir}),
	{ok, [PoolConfigList|_]} = file:consult(PoolConfigDir),
	% ?LOG(PoolConfigList),
	
	mysqlc_comm:start_pools(PoolConfigList),
	
	ok.


pool_config() -> 
	pool_config(2).

pool_config(PoolId) ->
	Root = glib:root_dir(),
	PoolConfigDir = lists:concat([Root, "db_pool.config"]),
	% ?LOG({"init pool", Root, PoolConfigDir}),
	{ok, [PoolConfigList|_]} = file:consult(PoolConfigDir),
	% ?LOG(PoolConfigList),
	lists:foldl(fun(#{
			pool_id := PoolId1,
			host := Host, 
		             port := Port, 
		             user := User, 
		             password := Password,
	            		database := Database
		} = PoolConfig, Reply) -> 
		case PoolId1 of
			PoolId -> 
				[PoolConfig|Reply];
			_ -> 
				Reply
		end 
	end, [], PoolConfigList).

