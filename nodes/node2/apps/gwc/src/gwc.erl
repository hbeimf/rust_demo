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
  R = wsc_common:call(PoolId, 1000, ReqPackage),
  ?LOG(R),
  ok.

%%  case R of
%%    {false, Reason} ->
%%      ?WRITE_LOG("exception", {exception, Reason}),
%%      ok;
%%    _ ->
%%%%      ?LOG(R),
%%      R
%%  end.



%%init() ->
%%  start_pool(),
%%  regiter_gw_2_gwc(),
%%  ok.
%%
%%regiter_gw_2_gwc() ->
%%  #{pool_id := PoolId} = config(),
%%  Works = wsc_common:works(PoolId),
%%  register_gw_2_gwc(Works, erlang:length(Works), 1).
%%
%%register_gw_2_gwc([], _Size, _WorkId) ->
%%  ok;
%%register_gw_2_gwc([{_, Pid, _, _}|OtherWork], Size, WorkId) ->
%%  RegisterConfig = register_config(Size, WorkId),
%%  Register = wsc_common:req(register_gw, RegisterConfig),
%%  Pid ! {send, Register},
%%  register_gw_2_gwc(OtherWork, Size, WorkId+1).
%%
%%start_pool() ->
%%  #{pool_id := PoolId, addr := Addr} = config(),
%%  wsc_common:dynamic_start_pool(PoolId, Addr, gwc_action),
%%  ok.
%%
%%%%config =================
%%register_config(Size, WorkId) ->
%%  #{
%%    cluster_id => sys_config:get_config(node, cluster_id)
%%    , node_id => sys_config:get_config(node, node_id)
%%%%    , addr => sys_config:get_config(node, addr)
%%    , size => Size
%%    , work_id => WorkId
%%  }.
%%
%%config() ->
%%  #{
%%    pool_id=>1,
%%    addr=> sys_config:get_config(hub, addr)
%%  }.