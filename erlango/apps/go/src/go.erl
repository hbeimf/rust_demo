-module(go).
-compile(export_all).

-define(TIMEOUT, 5000).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").

tt() ->
    cast(),
    ok.



test() -> 
	lists:foreach(fun(Id) -> 
		?LOG(Id),
		call()
	end, lists:seq(1, 100000)),
	ok.


call() ->
	ReqPackage = term_to_binary({<<"hello world!!">>, self()}),
    R = call(2001, ReqPackage),
    case R of 
    	{false, exception} -> 
    		ok;
    	_ -> 
		    R1 = binary_to_term(R),
		    ?LOG(R1),
		  	ok
	end,
    ok.

call(Cmd, ReqPackage) ->
	try 
		poolboy:transaction(pool_name(), fun(Worker) ->
			gen_server:call(Worker, {call, Cmd, ReqPackage}, ?TIMEOUT)
		end)
	catch 
			K:Error_msg->
				?WRITE_LOG("test_erlang_ds", {K, Error_msg, erlang:get_stacktrace()}),
				% glib:write_req({?MODULE, ?LINE, Req, erlang:get_stacktrace()}, "canBeModifyUserAccount-exception"),
				{false, exception}
	end.

cast() ->
    % cast(<<"hello world!">>).
	% Bin = term_to_binary({hello, world}),
	
    % Name = <<"test_name">>,
    % NickName = <<"test_nick_name">>,
    % Phone = <<"138912341234">>,
	% Bin = glib_pb:encode_TestMsg(Name, NickName, Phone),
	
	% Key = glib:to_binary(glib:uid()),	
	Key = base64:encode(term_to_binary({self()})),
	Cmd = 1000,
	Payload = term_to_binary({<<"hello world!!">>, self()}),
	Bin = glib_pb:encode_RpcPackage(Key, Cmd, Payload),
    cast(Bin).

cast(Package) ->
	% Key = to_binary(to_str(uid())),	
	% RpcPackage = #'RpcPackage'{
    %                     key = Key,
    %                     payload = Package
    %                 },
	% RpcPackageBin = msg_proto:encode_msg(RpcPackage),
    % RpcPackageBin1 = package(?CMD_CAST_10010, RpcPackageBin),
    
	poolboy:transaction(pool_name(), fun(Worker) ->
		gen_server:cast(Worker, {send, Package})
	end).


pool_name() ->
	go_pool.

uid() -> 
	esnowflake:generate_id().