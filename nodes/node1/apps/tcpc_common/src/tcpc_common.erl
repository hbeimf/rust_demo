%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2020 5:27 PM
%%%-------------------------------------------------------------------
-module(tcpc_common).
-author("mm").

-compile(export_all).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").

start_pool() ->
  Configs = config_list(),
  lists:foreach(fun(#{pool_id := PoolId, addr := _Addr}) ->
    start_pool(PoolId)
                end, Configs).

start_pool(PoolId) ->
  wsc_common_pool_sup:start_wsc_pool(PoolId).


pool_name(1)->
  tcpc_pool_1;
pool_name(2)->
  tcpc_pool_2;
pool_name(3)->
  tcpc_pool_3;
pool_name(4)->
  tcpc_pool_4;
pool_name(5)->
  tcpc_pool_5;
pool_name(6)->
  tcpc_pool_6;
pool_name(7)->
  tcpc_pool_7;
pool_name(8)->
  tcpc_pool_8;
pool_name(9)->
  tcpc_pool_9;
pool_name(10)->
  tcpc_pool_10;
pool_name(11)->
  tcpc_pool_11;
pool_name(_PoolId)->
  tcpc_pool_100.

pool_addr(PoolId) ->
  Configs = config_list(),
  Addr = addr(Configs, PoolId),
  Addr.

addr([], _PoolId) ->
  null;
addr([#{pool_id := PoolId, addr := Addr}|_], PoolId) ->
  Addr;
addr([#{pool_id := _Id, addr := _Addr}|OtherConfig], PoolId) ->
  addr(OtherConfig, PoolId).

% 获取配置文件
config_list() ->
  Key = wsc_common_config_list,
  case sys_config:get_config(Key) of
    {ok, Val} ->
      Val;
    _ ->
      Root = glib:root_dir(),
      PoolConfigDir = lists:concat([Root, "pool.config"]),
      % ?LOG({"init pool", Root, PoolConfigDir}),
      {ok, [PoolConfigList|_]} = file:consult(PoolConfigDir),
      sys_config:set_config(Key, PoolConfigList),
      PoolConfigList
  end.

