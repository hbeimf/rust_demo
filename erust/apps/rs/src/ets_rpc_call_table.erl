% ets_rpc_call_table.erl
% tcpc.erl
-module(ets_rpc_call_table).
-compile(export_all).

% -define(TIMEOUT, 5000).

-define(ETS_OPTS,[set, public ,named_table , {keypos,2}, {heir,none}, {write_concurrency,true}, {read_concurrency,false}]).

-define(RPC_CALL_DB, rpc_call_db).
-record(rpc_call_db, {
	key,
	val
}).

% ets_rpc_call_table:init_rpc_call_db().
init_rpc_call_db() ->
	ets:new(?RPC_CALL_DB, ?ETS_OPTS).

insert(Key, Val) ->
	ets:insert(?RPC_CALL_DB, #rpc_call_db{key=Key, val=Val}).

select(Key) -> 
	case ets:match_object(?RPC_CALL_DB, #rpc_call_db{key = Key,_='_'}) of
		[{?RPC_CALL_DB, Key, Val}] -> {ok, Val};
		[] ->{error,not_exist}
	end.

delete(Key) ->
	ets:delete(?RPC_CALL_DB, Key).
