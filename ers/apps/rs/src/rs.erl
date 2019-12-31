-module(rs).
-compile(export_all).


-define( UINT, 32/unsigned-little-integer).
% -define( INT, 32/signed-little-integer).
-define( USHORT, 16/unsigned-little-integer).
% -define( SHORT, 16/signed-little-integer).
% -define( UBYTE, 8/unsigned-little-integer).
% -define( BYTE, 8/signed-little-integer).

-define(TIMEOUT, 5000).

-include("msg_proto.hrl").
-include("cmd.hrl").
-include("log.hrl").

test() -> 
	aes_test(),
	aes_test1().

tt() -> 
	lists:foreach(fun(Id) -> 
		?LOG(Id),
		aes_test1()
	end, lists:seq(1, 100000)),
	ok.


% message AesEncode{   
%     string  key = 1;
%     string  from = 2;
% }

aes_test() -> 
	Str = <<"hello world">>,
	Key = <<"123456">>,
	Encode = aes_encode(Str, Key),
	?LOG(Encode),
	Decode = aes_decode(Encode, <<"1234567">>),
	?LOG(Decode),
	ok.

aes_test1() -> 
	Str = <<"hello world">>,
	Key = <<"123456">>,
	Encode = aes_encode(Str, Key),
	?LOG(Encode),
	% Decode = aes_decode(Encode, Key),
	% ?LOG(Decode),
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
	try 
		Key = to_binary(to_str(uid())),	
		RpcPackage = #'RpcPackage'{
							key = Key,
							cmd = Cmd,
							payload = Package
						},
		RpcPackageBin = msg_proto:encode_msg(RpcPackage),
		RpcPackageBin1 = package(?CMD_CALL_10008, RpcPackageBin),
		poolboy:transaction(pool_name(), fun(Worker) ->
			gen_server:call(Worker, {call, Key, RpcPackageBin1}, ?TIMEOUT)
		end)
	catch 
			_K:_Error_msg->
				% glib:write_req({?MODULE, ?LINE, Req, erlang:get_stacktrace()}, "canBeModifyUserAccount-exception"),
				{false, exception}
	end.



cast(Package) ->
	Key = to_binary(to_str(uid())),	
	RpcPackage = #'RpcPackage'{
                        key = Key,
                        payload = Package
                    },
	RpcPackageBin = msg_proto:encode_msg(RpcPackage),
	RpcPackageBin1 = package(?CMD_CAST_10010, RpcPackageBin),
	poolboy:transaction(pool_name(), fun(Worker) ->
		gen_server:cast(Worker, {send, RpcPackageBin1})
	end).


pool_name() ->
	rs_client_pool.

uid() -> 
	esnowflake:generate_id().

to_str(X) when is_list(X) -> X;
to_str(X) when is_atom(X) -> atom_to_list(X);
to_str(X) when is_binary(X) -> binary_to_list(X);
to_str(X) when is_integer(X) -> integer_to_list(X);
to_str(X) when is_float(X) -> float_to_list(X).

to_binary(X) when is_list(X) -> list_to_binary(X);
to_binary(X) when is_atom(X) -> list_to_binary(atom_to_list(X));
to_binary(X) when is_binary(X) -> X;
to_binary(X) when is_integer(X) -> list_to_binary(integer_to_list(X));
to_binary(X) when is_float(X) -> list_to_binary(float_to_list(X));
to_binary(X) -> term_to_binary(X).


unpackage(PackageBin) when erlang:byte_size(PackageBin) >= 4 ->
	% io:format("parse package =========~n~n"),
	case parse_head(PackageBin) of
		{ok, PackageLen} ->	
			parse_body(PackageLen, PackageBin);
		Any -> 
			Any
	end;
unpackage(_) ->
	{ok, waitmore}. 

parse_head(<<PackageLen:?UINT ,_/binary>> ) ->
	% io:format("parse head ======: ~p ~n~n", [PackageLen]), 
	{ok, PackageLen};
parse_head(_) ->
	error.

parse_body(PackageLen, _ ) when PackageLen > 9000 ->
	error; 
parse_body(PackageLen, PackageBin) ->
	% io:format("parse body -----------~n~n"),
	case PackageBin of 
		<<RightPackage:PackageLen/binary,NextPageckage/binary>> ->
			<<_Len:?UINT, Cmd:?UINT, DataBin/binary>> = RightPackage,
			% tcp_controller:action(Cmd, DataBin),
			% unpackage(NextPageckage);
			{ok, {Cmd, DataBin}, NextPageckage};
		_ -> {ok, waitmore}
	end.

package(Cmd, DataBin) ->
	Len = byte_size(DataBin)+8,
	<<Len:?UINT, Cmd:?UINT, DataBin/binary>>.