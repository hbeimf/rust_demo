% rs.erl
-module(rs).
-compile(export_all).

-define(TIMEOUT, 5000).

-include("msg_proto.hrl").
-include_lib("glib/include/log.hrl").
% -include_lib("glib/include/cmdid.hrl").


test() -> 
	Package = <<"hello world">>,
	call(Package).
	
call(Package) ->
	Key = glib:to_binary(glib:to_str(glib:uid())),	
	?LOG({key, Key}),
	% tcp_rpc_call_table:insert(Key, self()),

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
