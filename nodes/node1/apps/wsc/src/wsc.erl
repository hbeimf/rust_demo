-module(wsc).
-compile(export_all).

-define(TIMEOUT, 5000).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").

tt() ->
    cast(),
    ok.



test() -> 
	?WRITE_LOG("time", {start_time, glib:time(), glib:date_str()}),
	lists:foreach(fun(Id) -> 
		?LOG(Id),
		case call() of 
			{<<"hello world!!">>, _Pid} ->
				ok;
			Any ->
				?WRITE_LOG("call-fail", {Any}),
				ok
		end
	end, lists:seq(1, 1000000)),
	?WRITE_LOG("time", {end_time, glib:time(), glib:date_str()}),
	ok.


call() ->
	ReqPackage = term_to_binary({<<"hello world!!">>, self()}),
    R = call(2001, ReqPackage),
    case R of 
    	{false, Reason} -> 
    		?WRITE_LOG("exception", {exception, Reason}),
    		ok;
    	% {false, link_exception}->
    	% 	?WRITE_LOG("exception", {link_exception}),
    	% 	ok;
    	_ -> 
		    R1 = binary_to_term(R),
		    ?LOG(R1),
		  	% ok
		  	R1
	end.

call(Cmd, ReqPackage) -> 
	case try_call(Cmd, ReqPackage) of
		 {false, exception} ->
		 	call(Cmd, ReqPackage);
		 Reply -> 
		 	Reply
	end.


try_call(Cmd, ReqPackage) ->
	try 
		poolboy:transaction(pool_name(), fun(Worker) ->
			gen_server:call(Worker, {call, Cmd, ReqPackage}, ?TIMEOUT)
		end)
	catch 
			K:Error_msg->
				% ?WRITE_LOG("call_exception", {K, gap_xx, Error_msg, gap_xx, erlang:get_stacktrace()}),
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
	wsc_pool.
