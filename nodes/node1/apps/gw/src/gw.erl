%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Jan 2020 12:01 PM
%%%-------------------------------------------------------------------
-module(gw).
-author("mm").

-compile(export_all).

-define(TIMEOUT, 5000).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").
-include_lib("glib/include/rr.hrl").

test() ->
  ?LOG(test),
  ok.

ping() ->
  PoolId = 1,
  Cmd = ping,
  Req = {ping},
  R = pools:call(PoolId, Cmd, Req),
  ?LOG(R),
  ok.

call_fun() ->
  PoolId = 1,
  ReqPackage = {glib, replace, ["helloworld", "world", " you"]},
  R = pools:call(PoolId, call_fun, ReqPackage),
  ?LOG(R),
  ok.



