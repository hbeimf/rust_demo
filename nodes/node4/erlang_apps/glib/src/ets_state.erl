% ets_ac_key.erl
-module(ets_state).
-compile(export_all).

% -define(TIMEOUT, 5000).

-include_lib("glib/include/log.hrl").

-define(ETS_OPTS,[set, public ,named_table , {keypos,2}, {heir,none}, {write_concurrency,true}, {read_concurrency,false}]).
-define(CALL_DB, call_ets_state).


-record(call_ets_state, {
	key,
	val
}).

init_call_db() ->
	?LOG(init_call_db),
	ets:new(?CALL_DB, ?ETS_OPTS).

insert(Key, Val) ->
	ets:insert(?CALL_DB, #call_ets_state{key=Key, val= term_to_binary(Val)}).

select(Key) -> 
	case ets:match_object(?CALL_DB, #call_ets_state{key = Key,_='_'}) of
		[{?CALL_DB, Key, Val}] -> {ok, binary_to_term(Val)};
		[] ->{error,not_exist}
	end.

delete(Key) ->
	ets:delete(?CALL_DB, Key).

%% =============================================
% ets_state:test().
test() -> 
	Key = <<"1_VBJROPYE">>,
	insert(Key, Key),
	Row = select(Key),
	?LOG(Row),
	R1 = delete(Key),
	R2 = delete(2),
	?LOG({R1, R2}),
	ok.

