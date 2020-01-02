%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Dec 2019 8:01 PM
%%%-------------------------------------------------------------------
-module(wsc_common).

-compile(export_all).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").

start_pool() ->
  lists:foreach(fun(Id)->
    start_pool(Id)
                end, lists:seq(1, 10)).

start_pool(PoolId) ->
  wsc_common_pool_sup:start_wsc_pool(PoolId).


pool_name(1)->
  pool_1;
pool_name(2)->
  pool_2;
pool_name(3)->
  pool_3;
pool_name(4)->
  pool_4;
pool_name(5)->
  pool_5;
pool_name(6)->
  pool_6;
pool_name(7)->
  pool_7;
pool_name(8)->
  pool_8;
pool_name(9)->
  pool_9;
pool_name(10)->
  pool_10;
pool_name(_PoolId)->
  pool_100.

pool_addr(_PoolId) ->
  "ws://localhost:5678/ws".


