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
	Encode = aes_encode(Str, Key),
	?LOG(Encode),
	Decode = aes_decode(Encode, Key),
	?LOG(Decode),
	ok.

aes_encode(Str, Key) ->
	AesEncode = #'AesEncode'{
                        key = Key,
                        from = Str
                    },
	AesEncodeBin = msg_proto:encode_msg(AesEncode),
	call(AesEncodeBin, ?CMD_CALL_1001).
	
aes_decode(Encode, Key) ->
	AesDecode = #'AesDecode'{
                        key = Key,
                        from = Encode
                    },
	AesDecodeBin = msg_proto:encode_msg(AesDecode),
	Reply = call(AesDecodeBin, ?CMD_CALL_1003),

	#'AesDecodeReply'{code = Code, reply = MaybeDecode} 
		= msg_proto:decode_msg(Reply,'AesDecodeReply'),
	{Code, MaybeDecode}.
 	
%% priv	
call(Package, Cmd) ->
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
