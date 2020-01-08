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
  #{pool_id := PoolId} = config(),
  Works = wsc_common:works(PoolId),
%%  ?LOG(Works),
  RegisterConfig = register_config(),
  Register = wsc_common:req(register_gw, RegisterConfig),
  lists:foreach(
    fun({_, Pid, _, _}) ->
      Pid ! {send, Register}
    end, Works),
  ok.


start_pool() ->
  #{pool_id := PoolId, addr := Addr} = config(),
  wsc_common:dynamic_start_pool(PoolId, Addr),
  ok.

%%config =================
register_config() ->
  #{
    cluster_id => sys_config:get_config(node, cluster_id)
    , node_id => sys_config:get_config(node, node_id)
    , addr => sys_config:get_config(node, addr)
    , size => 10
  }.

config() ->
  #{
    pool_id=>1,
    addr=> sys_config:get_config(hub, addr)
  }.