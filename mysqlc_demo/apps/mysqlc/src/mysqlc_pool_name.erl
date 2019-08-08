% pool_name.erl
-module(mysqlc_pool_name).
-compile(export_all).

% mysqlc_pool_name:pool_name(ChannelId).
pool_name(ChannelId) ->
	PoolName = lists:concat(["pool_channel_", ChannelId]),
	to_atom(PoolName).


to_atom(A) when is_atom(A) ->
    A;
to_atom(B) when is_binary(B) ->
    list_to_atom(binary_to_list(B));
to_atom(L) when is_list(L) ->
    list_to_atom(L).

