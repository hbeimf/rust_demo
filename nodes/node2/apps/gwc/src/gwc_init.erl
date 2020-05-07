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
-include_lib("glib/include/cmd.hrl").

init() ->
  start_pool(),
  regiter_gw_2_gwc(),
  ok.

% regiter_gw_2_gwc() ->
%   #{pool_id := PoolId} = config(),
%   Works = wsc_common:works(PoolId),
%   register_gw_2_gwc(Works, erlang:length(Works), 1).

register_gw_2_gwc([], _Size, _WorkId) ->
  ok;
register_gw_2_gwc([{_, Pid, _, _}|OtherWork], Size, WorkId) ->
  RegisterConfig = register_config(Size, WorkId),
  Register = wsc_common:req(register_gw, RegisterConfig),
  Msg = glib_pb:encode_Msg(?CMD_REGISTER, Register),
  Pid ! {init_send, Msg},
  register_gw_2_gwc(OtherWork, Size, WorkId+1).

regiter_gw_2_gwc() ->
  ConfigList = glib_config:hubs(),
  lists:foreach(fun(#{pool_id := PoolId, addr := _Addr}) -> 
    Works = wsc_common:works(PoolId),
    register_gw_2_gwc(Works, erlang:length(Works), 1)
  end ,ConfigList),
  ok.


% start_pool() ->
%   #{pool_id := PoolId, addr := Addr} = config(),
%   wsc_common:dynamic_start_pool(PoolId, Addr, gwc_action),
%   ok.

start_pool() -> 
  ConfigList = glib_config:hubs(),
  lists:foreach(
    fun(#{pool_id := PoolId, addr := Addr}) -> 
      ?LOG({PoolId, Addr}),
      wsc_common:dynamic_start_pool(PoolId, Addr, gwc_action),
      ok
    end, ConfigList).

%%config =================
register_config(Size, WorkId) ->
  ClusterId = cluster(sys_config:get_config(node, cluster_id)),
  #{
    % cluster_id => sys_config:get_config(node, cluster_id)
    cluster_id => ClusterId
    , node_id => sys_config:get_config(node, node_id)
    , size => Size
    , work_id => WorkId
  }.

% config() ->
%   #{
%     pool_id=>1,
%     addr=> sys_config:get_config(hub, addr)
%   }.


cluster(1) ->
  pool_gw_1;
cluster(2) ->
  pool_gw_2;
cluster(3) ->
  pool_gw_3;
cluster(4) ->
  pool_gw_4;
cluster(5) ->
  pool_gw_5;
cluster(6) ->
  pool_gw_6;
cluster(7) ->
  pool_gw_7;
cluster(8) ->
  pool_gw_8;
cluster(9) ->
  pool_gw_9;
cluster(10) ->
  pool_gw_10;
cluster(_) ->
  pool_gw_100.


  