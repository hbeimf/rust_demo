%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Jan 2020 4:16 PM
%%%-------------------------------------------------------------------
-module(gwc).
-author("mm").
-compile(export_all).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").


t_pub() ->
  t_pub(1).
t_pub(PoolId) ->
  Cmd = test_pub_cmd,
  wsc_common:pub(PoolId, Cmd, {pub, test}),
  ok.

t_send() ->
  t_send(1),
  ok.
t_send(PoolId) ->
  wsc_common:send(PoolId, {send, test}),
  ok.

t_call() ->
  PoolId = 1,
  ReqPackage = {glib, replace, ["helloworld", "world", " you"]},
  R = wsc_common:call(PoolId, call_fun, ReqPackage),
  ?LOG(R),
  ok.





ping_pong() ->
  PoolId = 1,
  ReqPackage = ping,
  R = wsc_common:call(PoolId, ping, ReqPackage),
  ?LOG(R),
  ok.

call_fun() ->
  PoolId = 1,
  ReqPackage = {glib, replace, ["helloworld", "world", " you"]},
  R = wsc_common:call(PoolId, call_fun, ReqPackage),
  ?LOG(R),
  ok.



ping() ->
  Cmd = ping,
  Req = {cast_ping},
  PoolId = 1,
  wsc_common:cast(PoolId, Cmd, Req).


