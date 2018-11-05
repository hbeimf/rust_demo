-module(send).
-compile(export_all).

-define(ETS_OPTS,[set, public ,named_table , {keypos,2}, {heir,none}, {write_concurrency,true}, {read_concurrency,false}]).

-define(WS_CLIENTS, ws_clients).
-record(ws_clients, {
	key,
	val
}).

test() -> 
	Txt = <<"hello world">>,
	% {ok, Pid} = wsc_cc:start_link(),
	{ok, Pid} = get_client(),
	% Pid ! {binary, <<Bin/binary,Bin/binary,Bin/binary>>},
	Pid ! {text, Txt},
	ok.

% test_bin() -> 
% 	Bin = create_package(),
% 	% binary(PackageBinary).
% 	{ok, Pid} = wsc_cc:start_link(),
% 	% Pid ! {binary, <<Bin/binary,Bin/binary,Bin/binary>>},
% 	Pid ! {binary, Bin},
% 	ok.
		
create_package() -> 
	<<"hello world">>.


get_client() ->
	get_client(1).

get_client(Index) -> 
	case ets:match_object(?WS_CLIENTS, #ws_clients{key = Index,_='_'}) of
		[{?WS_CLIENTS, Key, Val}] -> {ok, Val};
		[] ->{error,not_exist}
	end.

init() -> 
	init_ws_clients().

init_ws_clients() -> 
	ets:new(?WS_CLIENTS, ?ETS_OPTS),
	lists:foreach(fun(Index) -> 
		{ok, Pid} = wsc_cc:start_link(Index),
		ets:insert(?WS_CLIENTS, #ws_clients{key=Index, val=Pid})
	end, [1,2,3,4,5,6]),

	ok.

