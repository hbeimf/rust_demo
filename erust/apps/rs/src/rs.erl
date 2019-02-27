-module(rs).
-compile(export_all).

-define(TIMEOUT, 5000).

-include("msg_proto.hrl").
-include("cmd.hrl").
-include("log.hrl").

test() -> 
	test_call(),
	test_cast().

test_call() -> 
	Package = <<"hello world">>,
	RpcReply = call(Package),
	?LOG(RpcReply),
	case RpcReply of 
		{error,connect_fail} ->
			ok;
		_ ->
			#'RpcPackage'{key = Key, 'payload' = Payload} = msg_proto:decode_msg(RpcReply,'RpcPackage'),
			?LOG(Payload),
			ok
	end,
	ok.

test_cast() -> 
	Package = <<"hello world">>,
	RpcReply = cast(Package).	
	
call(Package) ->
	Key = glib:to_binary(glib:to_str(glib:uid())),	
	RpcPackage = #'RpcPackage'{
                        key = Key,
                        payload = Package
                    },
	RpcPackageBin = msg_proto:encode_msg(RpcPackage),
	RpcPackageBin1 = glib:package(?CMD_CALL_10008, RpcPackageBin),
	poolboy:transaction(pool_name(), fun(Worker) ->
		gen_server:call(Worker, {call, Key, RpcPackageBin1}, ?TIMEOUT)
	end).



cast(Package) ->
	Key = glib:to_binary(glib:to_str(glib:uid())),	
	RpcPackage = #'RpcPackage'{
                        key = Key,
                        payload = Package
                    },
	RpcPackageBin = msg_proto:encode_msg(RpcPackage),
	RpcPackageBin1 = glib:package(?CMD_CAST_10010, RpcPackageBin),
	poolboy:transaction(pool_name(), fun(Worker) ->
		gen_server:cast(Worker, {send, RpcPackageBin1})
	end).


pool_name() ->
	rs_client_pool.
