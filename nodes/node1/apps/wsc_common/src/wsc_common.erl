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

-define(TIMEOUT, 5000).

start_pool() ->
  Configs = config_list(),
  lists:foreach(fun(#{pool_id := PoolId, addr := _Addr}) ->
                start_pool(PoolId)
                end, Configs).

start_pool(PoolId) ->
  wsc_common_pool_sup:start_wsc_pool(PoolId).

dynamic_start_pool(PoolId) ->
  update_config_list(),
  start_pool(PoolId).

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
pool_name(11)->
  pool_11;
pool_name(_PoolId)->
  pool_100.

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
  Key = key(),
  case sys_config:get_config(Key) of
    {ok, Val} ->
      Val;
    _ ->
      update_config_list()
  end.

key() ->
  wsc_common_config_list.

update_config_list() ->
  Key = key(),
  Root = glib:root_dir(),
  PoolConfigDir = lists:concat([Root, "pool_addr.config"]),
  % ?LOG({"init pool", Root, PoolConfigDir}),
  {ok, [PoolConfigList|_]} = file:consult(PoolConfigDir),
  sys_config:set_config(Key, PoolConfigList),
  PoolConfigList.

% {send, Cmd, ReqPackage}
cast(PoolId, Cmd, Package) ->
  ?LOG({cast, Cmd, Package}),
  poolboy:transaction(wsc_common:pool_name(PoolId), fun(Worker) ->
    gen_server:cast(Worker, {send, Cmd, Package})
                                                    end).

%%wsc:rpc(1003, {glib, replace, ["helloworld", "world", " you"]}).
rpc(PoolId, Req) ->
%%  ?LOG({Cmd, Req}),
  call(PoolId, 1003, Req).

call(PoolId, Cmd, ReqPackage) ->
  call(PoolId, Cmd, ReqPackage, 1, 3).

call(PoolId, Cmd, ReqPackage, Time, FailTime) ->
  case try_call(PoolId, Cmd, ReqPackage) of
    {false, exception} ->
      case Time < FailTime of
        true ->
          call(PoolId, Cmd, ReqPackage, Time+1, FailTime);
        _ ->
          ?WRITE_LOG("call_exception", {PoolId, Cmd, ReqPackage}),
          {false, exception}
      end;
    Reply ->
      Reply
  end.


try_call(PoolId, Cmd, ReqPackage) ->
  try
    poolboy:transaction(wsc_common:pool_name(PoolId),
      fun(Worker) ->
        gen_server:call(Worker, {call, Cmd, ReqPackage}, ?TIMEOUT)
      end)
  catch
    _K:_Error_msg ->
      % ?WRITE_LOG("call_exception", {K, gap_xx, Error_msg, gap_xx, erlang:get_stacktrace()}),
      {false, exception}
  end.

status() ->
  Children = wsc_common_pool_sup:children(),
  Status = lists:foldl(
    fun({_,Pid,_,_} = _Child, Reply) ->
      [{PoolName,PoolPid,_,_}|_] = wsc_common_sup_sup:children(Pid),
      Status1 = poolboy:status(PoolPid),
%%      ?LOG({PoolName, Status}),
      [{PoolName, Status1}|Reply]
    end, [], Children),
  ?LOG(Status),
  Status.
