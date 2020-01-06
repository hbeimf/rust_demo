-module(wscc).
-compile(export_all).



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
  R = wsc_common:call(PoolId, 1000, ReqPackage),
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
  R = wsc_common:rpc(PoolId, {glib, time, []}),
  ?LOG(R),
  R1 = wsc_common:rpc(PoolId, {glib, replace, ["helloworld", "world", " you"]}),
  ?LOG(R1),
  ok.

t() ->
  ?WRITE_LOG("time", {start_time, glib:time(), glib:date_str()}),
%%  PoolId = t_pool_id(),
  lists:foreach(fun(Index) ->
%%    ?LOG(Index),
    PoolId = t_pool_id(),
    Reply = wsc_common:rpc(PoolId, {glib, replace, ["helloworld", "world", " you"]}),
    ?LOG({PoolId, Index, Reply}),
    ok
                end, lists:seq(1, 100)),
  ?WRITE_LOG("time", {end_time, glib:time(), glib:date_str()}),
  ok.


t_all() ->
  ?WRITE_LOG("time", {start_time, glib:time(), glib:date_str()}),
%%  PoolId = t_pool_id(),
  lists:foreach(fun(Index) ->
%%    ?LOG(Index),
%%    PoolId = t_pool_id(),
%%    Reply = wsc_common:rpc(PoolId, {glib, replace, ["helloworld", "world", " you"]}),
    Reply = ping_all(),
    ?LOG({Index, Reply}),
    ok
                end, lists:seq(1, 100000)),
  ?WRITE_LOG("time", {end_time, glib:time(), glib:date_str()}),
  ok.



cast(Id) ->
  % Key = base64:encode(term_to_binary({self()})),
  Cmd = 1003,
  % Payload = term_to_binary({<<"hello world!!">>, self()}),
  Req = {Id},
  PoolId = 1,
  % Bin = glib_pb:encode_RpcPackage(Key, Cmd, Payload),
  wsc_common:cast(PoolId, Cmd, Req).


status() ->
  wsc_common:status().


%%get_all_workers

works() ->
  wsc_common:works(1).

ping_other() ->
  PoolId = t_pool_id(),
  ReqPackage = ping,
  R = wsc_common:call_other(PoolId, 1000, ReqPackage),
  case R of
    {false, Reason} ->
      ?WRITE_LOG("exception", {exception, Reason}),
      ok;
    _ ->
      ?LOG(R),
      R
  end.

ping_all() ->
%%  PoolId = t_pool_id(),
  ReqPackage = ping,
  R = wsc_common:call_all(1000, ReqPackage),
  case R of
    {false, Reason} ->
      ?WRITE_LOG("exception", {exception, Reason}),
      ok;
    _ ->
      ?LOG(R),
      R
  end.

c1() ->
  C1 = erlang:system_info(process_count),
  ?LOG(C1),
  ok.

s1(PoolId) ->
  C1 = erlang:system_info(process_count),
  ?LOG(C1),
  wsc_common:dynamic_start_pool(PoolId, "ws://localhost:5678/ws"),
  C2 = erlang:system_info(process_count),
  ?LOG(C2),
  ok.

s2(PoolId) ->
  C1 = erlang:system_info(process_count),
  ?LOG(C1),
%%  wsc_common:dynamic_start_pool(PoolId, "ws://localhost:5678/ws"),
  C2 = erlang:system_info(process_count),
  wsc_common:stop_pool(PoolId),
  ?LOG(C2),
  ok.
