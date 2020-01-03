-module(tcpcc).
-compile(export_all).

-define(TIMEOUT, 5000).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").
-include_lib("glib/include/cmd.hrl").


tt() ->
  % cast(),
  ?WRITE_LOG("time", {start_time, glib:time(), glib:date_str()}),
  lists:foreach(fun(Id) ->
    ?LOG(Id),
    cast(Id)
                end, lists:seq(1, 1000000)),
  ?WRITE_LOG("time", {end_time, glib:time(), glib:date_str()}),
  ok.



test() ->
  ?WRITE_LOG("time", {start_time, glib:time(), glib:date_str()}),
  lists:foreach(fun(Id) ->
    ?LOG(Id),
    case ping() of
      pong ->
        ok;
      Any ->
        ?LOG(fail),
        ?WRITE_LOG("call-fail", {Any}),
        ok
    end
                end, lists:seq(1, 1000000)),
  ?WRITE_LOG("time", {end_time, glib:time(), glib:date_str()}),
  ok.


ping() ->
  ReqPackage = ping,
  R = call(1, 1000, ReqPackage),
  case R of
    {false, Reason} ->
      ?LOG({false, Reason}),
      ?WRITE_LOG("exception", {exception, Reason}),
      ok;
    _ ->
      ?LOG(R),
      R
  end.

call(PoolId, Cmd, ReqPackage) ->
  case try_call(PoolId, Cmd, ReqPackage) of
    {false, exception} ->
      call(PoolId, Cmd, ReqPackage);
    Reply ->
      Reply
  end.


try_call(PoolId, Cmd, ReqPackage) ->
  try
    poolboy:transaction(tcpc_common:pool_name(PoolId), fun(Worker) ->
      gen_server:call(Worker, {call, Cmd, ReqPackage}, ?TIMEOUT)
                                     end)
  catch
    _K:_Error_msg->
      % ?WRITE_LOG("call_exception", {K, gap_xx, Error_msg, gap_xx, erlang:get_stacktrace()}),
      {false, exception}
  end.


cast() ->
  cast(123).

cast(Id) ->
  ?LOG(Id),
  % Key = base64:encode(term_to_binary({self()})),
  % Cmd = 1003,
  % Payload = term_to_binary({<<"hello world!!">>, self()}),
  Req = {Id},
  PoolId = 1,
  % Bin = glib_pb:encode_RpcPackage(Key, Cmd, Payload),
  cast(PoolId, ?CMD_1000, Req).

% {send, Cmd, ReqPackage}
cast(PoolId, Cmd, Package) ->
  % ?LOG({cast, Cmd, Package}),
  poolboy:transaction(tcpc_common:pool_name(PoolId), fun(Worker) ->
    gen_server:cast(Worker, {send, Cmd, Package})
                                   end).



