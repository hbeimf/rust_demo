-module(rs).
-compile(export_all).

-define(TIMEOUT, 5000).

-include("msg_proto.hrl").
-include_lib("glib/include/log.hrl").

test() -> 
	Package = <<"hello world">>,
	RpcReply = call(Package),
	?LOG(RpcReply),

	#'RpcPackage'{key = Key, 'payload' = Payload} = msg_proto:decode_msg(RpcReply,'RpcPackage'),
	?LOG(Payload),

	ok.
	
call(Package) ->
	Key = glib:to_binary(glib:to_str(glib:uid())),	

	RpcPackage = #'RpcPackage'{
                        key = Key,
                        payload = Package
                    },
	RpcPackageBin = msg_proto:encode_msg(RpcPackage),

	RpcPackageBin1 = glib:package(10008, RpcPackageBin),

	poolboy:transaction(pool_name(), fun(Worker) ->
		gen_server:call(Worker, {call, Key, RpcPackageBin1}, ?TIMEOUT)
	end).

pool_name() ->
	rs_client_pool.
