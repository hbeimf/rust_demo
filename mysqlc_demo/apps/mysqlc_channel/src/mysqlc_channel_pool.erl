% mysqlc_channel_pool.erl
% mysqlc_pool.erl
% demo.erl
-module(mysqlc_channel_pool).

-include_lib("glib/include/log.hrl").
-compile(export_all).


init_pool() ->
	PoolConfigList = config_list(),
	mysqlc_comm:start_pools(PoolConfigList),
	ok.


pool_config() -> 
	pool_config(2).

pool_config(PoolId) ->
	PoolConfigList = config_list(),

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



% 获取配置文件
% mysqlc_channel_pool:config_list().
config_list() -> 
	Root = glib:root_dir(),
	PoolConfigDir = lists:concat([Root, "db_pool.config"]),
	% ?LOG({"init pool", Root, PoolConfigDir}),
	{ok, [PoolConfigList|_]} = file:consult(PoolConfigDir),
	PoolConfigList.
