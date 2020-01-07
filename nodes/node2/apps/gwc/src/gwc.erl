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

init() ->
  start_pool(),
  regiter_gw(),
  ok.


regiter_gw() ->

  ok.

start_pool() ->
  #{pool_id := PoolId, addr := Addr} = config(),
  wsc_common:dynamic_start_pool(PoolId, Addr),
  ok.


config() ->
  #{
    pool_id=>1,
    addr=> "ws://localhost:8899/ws"
  }.