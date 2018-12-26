-module(send).
-compile(export_all).

-define(ETS_OPTS,[set, public ,named_table , {keypos,2}, {heir,none}, {write_concurrency,true}, {read_concurrency,false}]).

-define(WS_CLIENTS, ws_clients).
-record(ws_clients, {
	key,
	val
}).


-include_lib("glib/include/msg_proto.hrl").
-include_lib("glib/include/log.hrl").
-include_lib("glib/include/cmdid.hrl").

% rpc call
call_from_pool() ->
	TestMsg = #'TestMsg'{
                        name = <<"jim green">>,
                        nick_name = <<"nick_name123456">>,
                        phone = <<"15912341234">> 
                    },
    TestMsgBin = msg_proto:encode_msg(TestMsg),
    Reply = tcpc:call(TestMsgBin),
    ?LOG({pool_reply, Reply}),
    #'TestMsg'{name = Name, 'nick_name' = NickName,
 	 phone= Phone} = msg_proto:decode_msg(Reply,'TestMsg'),
 	?LOG({Name, NickName, Phone}),
    ok.

call() -> 
	
	TestMsg = #'TestMsg'{
                        name = <<"jim green">>,
                        nick_name = <<"nick_name123456">>,
                        phone = <<"15912341234">> 
                    },
    TestMsgBin = msg_proto:encode_msg(TestMsg),

    Package = glib:package(123456, TestMsgBin),

    ?LOG({send_binary, Package}),
	{ok, Pid} = get_client(),

	R = tcp_client_handler:call_req(Pid, Package),
	?LOG({call_reply, R}),
	ok.


test() ->
	lists:foreach(fun(Index) -> 
		test1()
	end, lists:seq(1, 100)),
	ok.

test1() -> 
	TestMsg = #'TestMsg'{
                        name = <<"jim green">>,
                        nick_name = <<"nick_name123456">>,
                        phone = <<"15912341234">> 
                    },
    TestMsgBin = msg_proto:encode_msg(TestMsg),

    Package = glib:package(123456, TestMsgBin),

    ?LOG({send_binary, Package}),
	{ok, Pid} = get_client(),
	Pid ! {send, Package},
	ok.

		
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
		{ok, Pid} = tcp_client_handler:start_link(Index),
		ets:insert(?WS_CLIENTS, #ws_clients{key=Index, val=Pid})
	end, [1,2,3,4,5,6]),

	ok.

