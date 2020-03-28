% pools_call.erl

-module(pools_call).
-author("mm").

-compile(export_all).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").
-include_lib("glib/include/rr.hrl").

-define(TIMEOUT, 5000).

% pools_call:call().

call() -> 
	ReqPackage = {glib, replace, ["helloworld", "world", " you"]},
  	% R = pools:call(PoolId, call_fun, ReqPackage),
	call({1, call_fun, ReqPackage}).

call({PoolId, Cmd, ReqPackage}) -> 
	{ok, Pid} = pools_call_sup:start_actor(),
	R = gen_server:call(Pid, {call, PoolId, Cmd, ReqPackage}, ?TIMEOUT),
	% gen_server:call(Worker, {call, Cmd, ReqPackage}, ?TIMEOUT)
	?LOG(R),
	ok.
