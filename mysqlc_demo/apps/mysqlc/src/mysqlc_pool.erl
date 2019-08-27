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