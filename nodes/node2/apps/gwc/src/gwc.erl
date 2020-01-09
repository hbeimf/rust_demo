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

ping() ->
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

