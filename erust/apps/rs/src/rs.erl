-module(rs).
-compile(export_all).

-define(TIMEOUT, 5000).

-include("msg_proto.hrl").
-include("cmd.hrl").
-include("log.hrl").

test() -> 
	aes_encode().


% message AesEncode{   
%     string  key = 1;
%     string  from = 2;
% }

aes_encode() -> 
	Str = <<"hello world">>,
	Key = <<"123456">>,
	aes_encode(Str, Key).
aes_encode(Str, Key) ->
	AesEncode = #'AesEncode'{
                        key = Key,
                        from = Str
                    },
	AesEncodeBin = msg_proto:encode_msg(AesEncode),
	Encode = call(AesEncodeBin, ?CMD_CALL_1001),
	?LOG(Encode),
	ok. 




% test() -> 
% 	test_call(),
% 	test_cast().

% test_call() -> 
% 	Package = <<"hello world">>,
% 	RpcReply = call(Package, 100),
% 	?LOG(RpcReply),
% 	case RpcReply of 
% 		{error,connect_fail} ->
% 			ok;
% 		_ ->
% 			#'RpcPackage'{key = Key, cmd= Cmd, 'payload' = Payload} = msg_proto:decode_msg(RpcReply,'RpcPackage'),
% 			?LOG({Key, Cmd, Payload}),
% 			ok
% 	end,
% 	ok.

% test_cast() -> 
% 	Package = <<"hello world">>,
% 	cast(Package).	

call(Package, Cmd) ->
	RpcReply = call_send(Package, Cmd),
	case RpcReply of 
		{error,connect_fail} ->
			false;
		_ ->
			#'RpcPackage'{key = _Key, cmd= _Cmd, 'payload' = Payload} = msg_proto:decode_msg(RpcReply,'RpcPackage'),
			% ?LOG({Key, Cmd, Payload}),
			{ok, Payload}
	end.

	
call_send(Package, Cmd) ->
	Key = glib:to_binary(glib:to_str(glib:uid())),	
	RpcPackage = #'RpcPackage'{
                        key = Key,
                        cmd = Cmd,
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
