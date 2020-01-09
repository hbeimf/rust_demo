%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Jan 2020 12:47 PM
%%%-------------------------------------------------------------------
-module(gwc_init).
-author("mm").
-compile(export_all).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").

init() ->
  start_pool(),
  regiter_gw_2_gwc(),
  ok.

regiter_gw_2_gwc() ->
  #{pool_id := PoolId} = config(),
  Works = wsc_common:works(PoolId),
  register_gw_2_gwc(Works, erlang:length(Works), 1).

register_gw_2_gwc([], _Size, _WorkId) ->
  ok;
register_gw_2_gwc([{_, Pid, _, _}|OtherWork], Size, WorkId) ->
  RegisterConfig = register_config(Size, WorkId),
  Register = wsc_common:req(register_gw, RegisterConfig),
  Pid ! {init_send, Register},
  register_gw_2_gwc(OtherWork, Size, WorkId+1).

start_pool() ->
  #{pool_id := PoolId, addr := Addr} = config(),
  wsc_common:dynamic_start_pool(PoolId, Addr, gwc_action),
  ok.

%%config =================
register_config(Size, WorkId) ->
  #{
    cluster_id => sys_config:get_config(node, cluster_id)
    , node_id => sys_config:get_config(node, node_id)
    , size => Size
    , work_id => WorkId
  }.

config() ->
  #{
    pool_id=>1,
    addr=> sys_config:get_config(hub, addr)
  }.