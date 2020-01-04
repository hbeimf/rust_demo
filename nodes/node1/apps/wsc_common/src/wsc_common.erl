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

%%dynamic_start_pool(PoolId) ->
%%  set_config_list(),
%%  start_pool(PoolId).

dynamic_start_pool(PoolId, Addr) ->
  set_config_list(PoolId, Addr),
  start_pool(PoolId).

stop_pool(PoolId) ->
  ?LOG(PoolId),
%%  cleanup(PoolId),
  ok.

pool_name(PoolName) when is_atom(PoolName) ->
  PoolName;
pool_name(1) ->
  pool_1;
pool_name(2) ->
  pool_2;
pool_name(3) ->
  pool_3;
pool_name(4) ->
  pool_4;
pool_name(5) ->
  pool_5;
pool_name(6) ->
  pool_6;
pool_name(7) ->
  pool_7;
pool_name(8) ->
  pool_8;
pool_name(9) ->
  pool_9;
pool_name(10) ->
  pool_10;
pool_name(11) ->
  pool_11;
pool_name(12) ->
  pool_13;
pool_name(13) ->
  pool_13;
pool_name(14) ->
  pool_14;
pool_name(15) ->
  pool_15;
pool_name(16) ->
  pool_16;
pool_name(17) ->
  pool_17;
pool_name(18) ->
  pool_18;
pool_name(19) ->
  pool_19;
pool_name(20) ->
  pool_20;
pool_name(_PoolId) ->
  pool_100.

pool_addr(PoolId) ->
  Configs = config_list(),
  Addr = addr(Configs, PoolId),
  Addr.

addr([], _PoolId) ->
  null;
addr([#{pool_id := PoolId, addr := Addr} | _], PoolId) ->
  Addr;
addr([#{pool_id := _Id, addr := _Addr} | OtherConfig], PoolId) ->
  addr(OtherConfig, PoolId).

% 获取配置文件
config_list() ->
  Key = key(),
  case sys_config:get_config(Key) of
    {ok, Val} ->
      Val;
    _ ->
      set_config_list()
  end.

key() ->
  wsc_common_config_list.

set_config_list() ->
  Key = key(),
  Root = glib:root_dir(),
  PoolConfigDir = lists:concat([Root, "pool_addr.config"]),
  % ?LOG({"init pool", Root, PoolConfigDir}),
  PoolConfigList = case glib:file_exists(PoolConfigDir) of
                     true ->
                       {ok, [C | _]} = file:consult(PoolConfigDir),
                       C;
                     _ ->
                       []
                   end,
  sys_config:set_config(Key, PoolConfigList),
  PoolConfigList.

set_config_list(PoolId, Addr) ->
  Key = key(),
  Config = #{pool_id => PoolId, addr => Addr},
  ConfigList = config_list(),
  case lists:member(Config, ConfigList) of
    true ->
      ConfigList;
    _ ->
      NewConfigList = [Config | ConfigList],
      sys_config:set_config(Key, NewConfigList),
      NewConfigList
  end.

% {send, Cmd, ReqPackage}
cast(PoolId, Cmd, Package) ->
  ?LOG({cast, Cmd, Package}),
  case is_pool_alive(PoolId) of
    true ->
      poolboy:transaction(wsc_common:pool_name(PoolId), fun(Worker) ->
        gen_server:cast(Worker, {send, Cmd, Package})
                                                        end);
    _ ->
      ?WRITE_LOG("pool_exception", {PoolId, Cmd, Package}),
      start_pool(PoolId),
      false
  end.


%%wsc:rpc(1003, {glib, replace, ["helloworld", "world", " you"]}).
rpc(PoolId, Req) ->
%%  ?LOG({Cmd, Req}),
  call(PoolId, 1003, Req).

call_other(PoolId, Cmd, ReqPackage) ->
  StartedPool = started_pool(),
  PoolName = pool_name(PoolId),
  OtherPool = StartedPool -- [PoolName],
%%  ?LOG({StartedPool, PoolName, OtherPool}),
  Res = lists:foldl(
    fun(Pool, Reply) ->
      R = call(Pool, Cmd, ReqPackage),
      [{Pool, R}|Reply]
    end, [], OtherPool),
%%  ?LOG(Res),
  Res.


call(PoolId, Cmd, ReqPackage) ->
  call(PoolId, Cmd, ReqPackage, 1, 3).

call(PoolId, Cmd, ReqPackage, Time, FailTime) ->
  case try_call(PoolId, Cmd, ReqPackage) of
    {false, exception} ->
      case Time < FailTime of
        true ->
          call(PoolId, Cmd, ReqPackage, Time + 1, FailTime);
        _ ->
          ?WRITE_LOG("call_exception", {PoolId, Cmd, ReqPackage}),
          {false, exception}
      end;
    Reply ->
      Reply
  end.


try_call(PoolId, Cmd, ReqPackage) ->
  try
    case is_pool_alive(PoolId) of
      true ->
        poolboy:transaction(wsc_common:pool_name(PoolId),
          fun(Worker) ->
            gen_server:call(Worker, {call, Cmd, ReqPackage}, ?TIMEOUT)
          end);
      _ ->
        ?WRITE_LOG("pool_exception", {PoolId, Cmd, ReqPackage}),
        {false, exception}
    end
  catch
    _K:_Error_msg ->
      % ?WRITE_LOG("call_exception", {K, gap_xx, Error_msg, gap_xx, erlang:get_stacktrace()}),
      {false, exception}
  end.

status() ->
  Children = wsc_common_pool_sup:children(),
%%  ?LOG(Children),
  Status = lists:foldl(
    fun({_, Pid, _, _} = _Child, Reply) ->
      [{PoolName, PoolPid, _, _} | _] = wsc_common_sup_sup:children(Pid),
      Status1 = poolboy:status(PoolPid),
%%      ?LOG({PoolName, Status}),
      [{Pid, PoolName, Status1} | Reply]
    end, [], Children),
%%  ?LOG(Status),
  Status.

started_pool() ->
  Status = status(),
  lists:map(fun({_, P, _}) -> P end, Status).

%%cleanup(PoolId) ->
%%  Status = status(),
%%  cleanup(Status, pool_name(PoolId)).
%%
%%cleanup([], _PoolName) ->
%%  ok;
%%cleanup([{Pid, PoolName, _}|Other], PoolName) ->
%%  erlang:exit(Pid, kill),
%%  ?LOG({PoolName, Pid}),
%%  cleanup(Other, PoolName);
%%cleanup([_|Other], PoolName) ->
%%  cleanup(Other, PoolName).


works(PoolId) ->
  case is_pool_alive(PoolId) of
    true ->
      Works = gen_server:call(pool_name(PoolId), get_all_workers),
%%  ?LOG(Works),
      Works;
    _ ->
      []
  end.

pool_pid(PoolId) ->
  erlang:whereis(pool_name(PoolId)).

is_pool_alive(PoolId) ->
  PoolPid = pool_pid(PoolId),
  case PoolPid of
    undefined ->
      false;
    _ ->
      case erlang:is_pid(PoolPid) andalso erlang:is_process_alive(PoolPid) of
        true ->
          true;
        _ ->
          false
      end
  end.

%%wsc_common:pool_reconnect(1, "ws://localhost:5678/ws").
pool_reconnect(PoolId, Addr) ->
%%  ?LOG({PoolId, Addr}),
  Works = works(PoolId),
%%  ?LOG(Works),
  lists:foreach(
    fun({_, Pid, _, _}) ->
%%      ?LOG(Pid),
      case erlang:is_pid(Pid) andalso erlang:is_process_alive(Pid) of
        true ->
          Pid ! {reconnect, Addr},
          ok;
        _ ->
          ok
      end
    end, Works),
  ok.