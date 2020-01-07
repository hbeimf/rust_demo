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
  regiter_gw_2_gwc(),
  ok.

regiter_gw_2_gwc() ->
  #{cluster_id := ClusterId
    , node_id := NodeId
    , addr := Addr} = register_config(),
  #{pool_id := PoolId} = config(),
  wsc_common:cast(PoolId, register_gw, {ClusterId, NodeId, Addr}),
  ok.


start_pool() ->
  #{pool_id := PoolId, addr := Addr} = config(),
  wsc_common:dynamic_start_pool(PoolId, Addr),
  ok.

%%config =================
register_config() ->
  #{
    cluster_id => 1,
    node_id => 1,
    addr => "ws://localhost:5678/ws"
  }.

config() ->
  #{
    pool_id=>1,
    addr=> "ws://localhost:8899/ws"
  }.