% pools_call.erl

-module(pools_call).
-author("mm").

-compile(export_all).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").
-include_lib("glib/include/rr.hrl").

-define(TIMEOUT, 5000).

% erlang:system_info(process_count).
% pools_call:call().

test_call() -> 
	ReqPackage = {glib, replace, ["helloworld", "world", " you"]},
  	% R = pools:call(PoolId, call_fun, ReqPackage),
	call({1, call_fun, ReqPackage}).

call({PoolId, Cmd, ReqPackage}) -> 
	{ok, Pid} = pools_call_sup:start_actor(),
	R = gen_server:call(Pid, {call, PoolId, Cmd, ReqPackage}, ?TIMEOUT),
	% gen_server:call(Worker, {call, Cmd, ReqPackage}, ?TIMEOUT)
	% ?LOG(R),
	R.

% pools_call:test_call_gw_all().
test_call_gw_all() ->
	ReqPackage = {glib, replace, ["helloworld", "world", " you"]},
	Pools = pool_gw(),
	R = call_all(Pools, {call_fun, ReqPackage}),
	?LOG(R),
	ok.

call_all([], {_Cmd, _ReqPackage}) -> 
	ok;
call_all(Pools, {Cmd, ReqPackage}) ->
	lists:map(fun(PoolId) -> 
		% {ok, Pid} = pools_call_sup:start_actor(),
		% R = gen_server:call(Pid, {call, PoolId, Cmd, ReqPackage}, ?TIMEOUT),
		% R
		call({PoolId, Cmd, ReqPackage})
	end, Pools).


% pools_call:cc().
cc() -> 
	lists:foreach(fun(Id) -> 
		?LOG(Id),
		test_call_gw_all()
	end, lists:seq(1, 1000)).

cc(T) -> 
	lists:foreach(fun(Id) -> 
		?LOG(Id),
		test_call_gw_all()
	end, lists:seq(1, T)).

% % pools_call:group_pool().
% group_pool() -> 
% 	Pools = [pool_gw_1, pool_gw_2, pool_gw_3, pool_ac_1, pool_ac_2, pools_xx_1, pools_xx_2],
% 	R = group_pool(Pools, pool_gw),
% 	?LOG({pool_gw, R}),
% 	R1 = group_pool(Pools, pool_ac),
% 	?LOG({pool_ac, R1}),
% 	R2 = group_pool(Pools, pools_xx),
% 	?LOG({pools_xx, R2}),
% 	ok.


pool_ac() ->
	group_pool(pool_ac).

pool_gw() -> 
	group_pool(pool_gw).

group_pool(Group) ->
	Pools = pools:all_pool(),
	group_pool(Pools, Group).

group_pool(Pools, Group) -> 
	% ?LOG({Pools, Head}),
	Pools1 = lists:map(fun(Pool) -> 
		{Pool, glib:to_binary(Pool)}
	end, Pools),
	GroupBin = glib:to_binary(Group),
	lists:foldl(fun({P, PBin}, Reply) -> 
		case has_head(PBin, GroupBin) of
			true ->  
				[P|Reply];
			_ -> 
				Reply
		end
	end, [], Pools1).

% % pools_call:has_head().
% has_head() -> 
% 	has_head(<<"helloworld">>, <<"hello">>).

has_head(Bin, Head) ->
	case binary:match(Bin, Head) of 
		{0, _} ->
			true;
		_ -> 
			false
	end.

	% ?LOG({Bin, Head, R}),
	% ok.



