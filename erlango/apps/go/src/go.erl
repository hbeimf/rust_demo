-module(go).
-compile(export_all).

-define(TIMEOUT, 5000).

-include_lib("glib/include/log.hrl").

tt() ->
    cast(),
    ok.




call() ->
    call(<<"hello world">>, 100).

call(Package, _Cmd) ->
	try 
		% Key = to_binary(to_str(uid())),	
		% RpcPackage = #'RpcPackage'{
		% 					key = Key,
		% 					cmd = Cmd,
		% 					payload = Package
		% 				},
		% RpcPackageBin = msg_proto:encode_msg(RpcPackage),
        % RpcPackageBin1 = package(?CMD_CALL_10008, RpcPackageBin),
        
		poolboy:transaction(pool_name(), fun(Worker) ->
			gen_server:call(Worker, {call, Package}, ?TIMEOUT)
		end)
	catch 
			_K:_Error_msg->
				% glib:write_req({?MODULE, ?LINE, Req, erlang:get_stacktrace()}, "canBeModifyUserAccount-exception"),
				{false, exception}
	end.

cast() ->
    cast(<<"hello world!">>).

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