%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Jan 2020 11:48 AM
%%%-------------------------------------------------------------------
-module(gw_action).
-author("mm").

-compile(export_all).

-define(TIMEOUT, 5000).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").
-include_lib("glib/include/rr.hrl").


action(Package, State) ->
  #request{from = From, req_cmd = Cmd, req_data = ReqPackage} = binary_to_term(Package),
  action(Cmd, ReqPackage, From, State).

action(ping, Req, From, _State) ->
  % ?LOG({ping, Req, From}),
  case From of
    null ->
      ok;
    _ ->
      Reply = #reply{from = From, reply_code = 1001, reply_data = pong},
      self() ! {reply, Reply}
  end,
  ok;


% action(call_fun, ReqPackage, From, #{pool_id := PoolId} = State) ->
%   R = pools:call(PoolId, call_fun, ReqPackage),
%   % R = erlang:apply(Mod, F, Params),
%   Reply = #reply{from = From, reply_code = 1004, reply_data = R},
%   self() ! {reply, Reply},
%   ok;

action(call_fun, {Mod, F, Params} = ReqPackage, From, #{pool_id := PoolId} = State) ->
  R = pools:call_other(PoolId, call_fun, ReqPackage),
  Reply = #reply{from = From, reply_code = 1004, reply_data = R},
  self() ! {reply, Reply},
  ok;

action(register_gw, RegisterConfig, From, _State) ->
  ?LOG({register_gw, RegisterConfig, From, self()}),
  #{cluster_id := ClusterId,node_id := NodeId,size := Size, work_id := WorkId} = RegisterConfig,
  Node = sys_config:get_config(node, node_id),
  table_pools:add({ClusterId, NodeId, WorkId, Node}, Size, self(), ClusterId),
  pools:create_pool(ClusterId),
  {update_state, #{table_pools_id => {ClusterId, NodeId, WorkId}, pool_id => ClusterId}};



action(pub, {Cmd, Req}, From, #{pool_id := PoolId} = State) ->
%%  ?LOG({pub, Req, From, State}),
  pools:cast_other(PoolId, Cmd, Req),
  ok;

action(send, Req, From, State) ->
  ?LOG({send, Req, From, State}),
  ok;


action(Cmd, ReqPackage, From, State) ->
  ?LOG({Cmd, ReqPackage, From, State}),
  ok.




