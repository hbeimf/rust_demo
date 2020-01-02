-module(wscc).
-compile(export_all).

-define(TIMEOUT, 5000).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").

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
  PoolId = t_pool_id(),
  ReqPackage = ping,
  R = call(PoolId, 1000, ReqPackage),
  case R of
    {false, Reason} ->
      ?WRITE_LOG("exception", {exception, Reason}),
      ok;
    _ ->
      ?LOG(R),
      R
  end.

t_pool_id() ->
  PoolIds = lists:seq(1, 4),
  [PoolId | _] = glib:shuffle_list(PoolIds),
  PoolId.

rpc() ->
  PoolId = 1,
  R = rpc(PoolId, {glib, time, []}),
  ?LOG(R),
  R1 = rpc(PoolId, {glib, replace, ["helloworld", "world", " you"]}),
  ?LOG(R1),
  ok.

t() ->
  ?WRITE_LOG("time", {start_time, glib:time(), glib:date_str()}),
%%  PoolId = t_pool_id(),
  lists:foreach(fun(Index) ->
%%    ?LOG(Index),
    PoolId = t_pool_id(),
    Reply = rpc(PoolId, {glib, replace, ["helloworld", "world", " you"]}),
    ?LOG({PoolId, Index, Reply}),
    ok
                end, lists:seq(1, 1000000)),
  ?WRITE_LOG("time", {end_time, glib:time(), glib:date_str()}),
  ok.

%%wsc:rpc(1003, {glib, replace, ["helloworld", "world", " you"]}).
rpc(PoolId, Req) ->
%%  ?LOG({Cmd, Req}),
  call(PoolId, 1003, Req).

call(PoolId, Cmd, ReqPackage) ->
  call(PoolId, Cmd, ReqPackage, 1, 3).

call(PoolId, Cmd, ReqPackage, Time, FailTime) ->
  case try_call(PoolId, Cmd, ReqPackage) of
    {false, exception} ->
      case Time < FailTime of
        true ->
          call(PoolId, Cmd, ReqPackage, Time+1, FailTime);
        _ ->
          ?WRITE_LOG("call_exception", {PoolId, Cmd, ReqPackage}),
          {false, exception}
      end;
    Reply ->
      Reply
  end.


try_call(PoolId, Cmd, ReqPackage) ->
  try
    poolboy:transaction(wsc_common:pool_name(PoolId),
      fun(Worker) ->
        gen_server:call(Worker, {call, Cmd, ReqPackage}, ?TIMEOUT)
      end)
  catch
    _K:_Error_msg ->
      % ?WRITE_LOG("call_exception", {K, gap_xx, Error_msg, gap_xx, erlang:get_stacktrace()}),
      {false, exception}
  end.

cast(Id) ->
  % Key = base64:encode(term_to_binary({self()})),
  Cmd = 1003,
  % Payload = term_to_binary({<<"hello world!!">>, self()}),
  Req = {Id},
  PoolId = 1,
  % Bin = glib_pb:encode_RpcPackage(Key, Cmd, Payload),
  cast(PoolId, Cmd, Req).

% {send, Cmd, ReqPackage}
cast(PoolId, Cmd, Package) ->
  ?LOG({cast, Cmd, Package}),
  poolboy:transaction(wsc_common:pool_name(PoolId), fun(Worker) ->
    gen_server:cast(Worker, {send, Cmd, Package})
                                                    end).

