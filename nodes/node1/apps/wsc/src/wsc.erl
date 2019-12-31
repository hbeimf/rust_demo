-module(wsc).
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
  ReqPackage = ping,
  R = call(1000, ReqPackage),
  case R of
    {false, Reason} ->
      ?WRITE_LOG("exception", {exception, Reason}),
      ok;
    _ ->
      ?LOG(R),
      R
  end.


rpc() ->
  R = rpc(1003, {glib, time, []}),
  ?LOG(R),
  R1 = rpc(1003, {glib, replace, ["helloworld", "world", " you"]}),
  ?LOG(R1),
  ok.

t() ->
  ?WRITE_LOG("time", {start_time, glib:time(), glib:date_str()}),
  lists:foreach(fun(Index) ->
%%    ?LOG(Index),
    Reply = rpc(1003, {glib, replace, ["helloworld", "world", " you"]}),
    ?LOG({Index, Reply}),
    ok
                end, lists:seq(1, 1000000)),
  ?WRITE_LOG("time", {end_time, glib:time(), glib:date_str()}),
  ok.

%%wsc:rpc(1003, {glib, replace, ["helloworld", "world", " you"]}).
rpc(Cmd, Req) ->
%%  ?LOG({Cmd, Req}),
  call(Cmd, Req).

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
    K:Error_msg ->
      % ?WRITE_LOG("call_exception", {K, gap_xx, Error_msg, gap_xx, erlang:get_stacktrace()}),
      {false, exception}
  end.

cast(Id) ->
  % Key = base64:encode(term_to_binary({self()})),
  Cmd = 1003,
  % Payload = term_to_binary({<<"hello world!!">>, self()}),
  Req = {Id},
  % Bin = glib_pb:encode_RpcPackage(Key, Cmd, Payload),
  cast(Cmd, Req).

% {send, Cmd, ReqPackage}
cast(Cmd, Package) ->
  % ?LOG({cast, Cmd, Package}),
  poolboy:transaction(pool_name(), fun(Worker) ->
    gen_server:cast(Worker, {send, Cmd, Package})
                                   end).


pool_name() ->
  wsc_pool.
