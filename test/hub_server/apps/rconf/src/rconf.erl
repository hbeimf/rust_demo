-module(rconf).
-compile(export_all).


test() -> 
	read_config().

read_config() -> 
	read_config(mysql).

read_config(hub_server) -> 
	case read_config_file() of
		{ok, Config} -> 
			{_, {hub_server, ProxyServerConfig}, _ } = lists:keytake(hub_server, 1, Config),
			{_, {host, Host}, _} = lists:keytake(host, 1, ProxyServerConfig),
			{_, {port, Port}, _} = lists:keytake(port, 1, ProxyServerConfig),
			{Host, to_integer(Port)};
		_ -> 
			ok
	end;
read_config(redis) -> 
	case read_config_file() of
		{ok, Config} -> 
			{_, {redis, Redis}, _ } = lists:keytake(redis, 1, Config),
			{_, {host, Host}, _} = lists:keytake(host, 1, Redis),
			{_, {port, Port}, _} = lists:keytake(port, 1, Redis),
			% {_, {password, Password}, _} = lists:keytake(password, 1, Redis),
			case lists:keytake(password, 1, Redis) of
				{_, {password, Password}, _} -> 
					[{pool_redis,
						[{size,5},{max_overflow,20}], 
						[{host,Host},
							{port,to_integer(Port)},
							{password, Password},
							{reconnect_sleep,100}]}];
				_ -> 
					[{pool_redis,
						[{size,5},{max_overflow,20}], 
						[{host,Host},
							{port,to_integer(Port)},
							{reconnect_sleep,100}]}]
			end;
			
		_ -> 
			ok
	end;


read_config(user_center) -> 
	case read_config_file() of
		{ok, Config} -> 
			{_, {user_center, UserCenter}, _ } = lists:keytake(user_center, 1, Config),
			{_, {host, Host}, _} = lists:keytake(host, 1, UserCenter),
			{_, {port, Port}, _} = lists:keytake(port, 1, UserCenter),
			{Host, to_integer(Port)};
		_ -> 
			ok
	end;

read_config(mysql) -> 
	case read_config_file() of
		{ok, Config} -> 
			{_, {mysql, MysqlConfig}, _ } = lists:keytake(mysql, 1, Config),
			{_, {host, Host}, _} = lists:keytake(host, 1, MysqlConfig),
			{_, {port, Port}, _} = lists:keytake(port, 1, MysqlConfig),
			{_, {user, User}, _} = lists:keytake(user, 1, MysqlConfig),
			{_, {password, Password}, _} = lists:keytake(password, 1, MysqlConfig),
			{_, {database, Database}, _} = lists:keytake(database, 1, MysqlConfig),
			
			[{pool1,[{host, Host},
		         {port, to_integer(Port)},
		         {user,User},
		         {password, Password},
		         {database,Database},
		         {prepare,[{set_code,"set names utf8"}]}]}];

		_ -> 
			ok
	end.

read_config_file() -> 
	ConfigFile = root_dir() ++ "config.ini",
	case file_get_contents(ConfigFile) of
		{ok, Config} -> 
			zucchini:parse_string(Config);
		_ -> 
			ok
	end.

% rconf:root_dir().
root_dir() ->
	replace(os:cmd("pwd"), "\n", "/"). 

file_get_contents(Dir) ->
	case file:read_file(Dir) of
		{ok, Bin} ->
			% {ok, binary_to_list(Bin)};
			{ok, Bin};
		{error, Msg} ->
			{error, Msg}
	end.

file_put_contents(Dir, Str) ->
	file:write_file(Dir, to_binary(Str)).

file_exists(Dir) ->
	case filelib:is_dir(Dir) of
		true ->
			false;
		false ->
			filelib:is_file(Dir)
	end.

replace(Str, SubStr, NewStr) ->
	case string:str(Str, SubStr) of
		Pos when Pos == 0 ->
			Str;
		Pos when Pos == 1 ->
			Tail = string:substr(Str, string:len(SubStr) + 1),
			string:concat(NewStr, replace(Tail, SubStr, NewStr));
		Pos ->
			Head = string:substr(Str, 1, Pos - 1),
			Tail = string:substr(Str, Pos + string:len(SubStr)),
			string:concat(string:concat(Head, NewStr), replace(Tail, SubStr, NewStr))
	end.

to_binary(X) when is_list(X) -> list_to_binary(X);
to_binary(X) when is_atom(X) -> list_to_binary(atom_to_list(X));
to_binary(X) when is_binary(X) -> X;
to_binary(X) when is_integer(X) -> list_to_binary(integer_to_list(X));
to_binary(X) when is_float(X) -> list_to_binary(float_to_list(X));
to_binary(X) -> term_to_binary(X).


to_integer(X) when is_list(X) -> list_to_integer(X);
to_integer(X) when is_binary(X) -> binary_to_integer(X);
to_integer(X) when is_integer(X) -> X;
to_integer(X) -> X.