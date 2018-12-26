% tcpc.erl
-module(tcpc).
-compile(export_all).

-define(TIMEOUT, 5000).

-include_lib("glib/include/msg_proto.hrl").
-include_lib("glib/include/log.hrl").
-include_lib("glib/include/cmdid.hrl").


call(Package) ->
	Key = glib:to_str(glib:uid()),	
	tcp_rpc_call_table:insert(Key, self()),

	RpcPackage = #'RpcPackage'{
                        key = Key,
                        payload = Package
                    },
    RpcPackageBin = msg_proto:encode_msg(RpcPackage),
    RpcPackageBin1 = glib:package(10008, RpcPackageBin),


	poolboy:transaction(pool_name(), fun(Worker) ->
        gen_server:call(Worker, {call, RpcPackageBin1}, ?TIMEOUT)
    end).

pool_name() ->
	pool1.