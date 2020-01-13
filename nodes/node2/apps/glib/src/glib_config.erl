% glib_config.erl
-module(glib_config).
-compile(export_all).

-include_lib("glib/include/log.hrl").

hubs() -> 
	Root = glib:root_dir(),
	PoolConfigDir = lists:concat([Root, "hubs.config"]),
	{ok, [PoolConfigList|_]} = file:consult(PoolConfigDir),
	PoolConfigList.