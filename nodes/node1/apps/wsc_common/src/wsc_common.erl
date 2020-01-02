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
  start_pool(1).

start_pool(PoolId) ->
  wsc_common_sup:start_wsc_pool(PoolId).

pool_name(_)->
  pool_1.


