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
-include_lib("glib/include/cmd.hrl").


action(Msg, State) ->
  % #request{from = From, req_cmd = Cmd, req_data = ReqPackage} = binary_to_term(Package),
  % action(Cmd, ReqPackage, From, State).
  {Action, Package} = glib_pb:decode_Msg(Msg),
  action(Action, Package, State).
  % ok.

% action(ping, Req, From, _State) ->
%   % ?LOG({ping, Req, From}),
%   case From of
%     null ->
%       ok;
%     _ ->
%       Reply = #reply{from = From, reply_code = 1001, reply_data = pong},
%       self() ! {reply, Reply}
%   end,
%   ok;


% action(call_fun, {Mod, F, Params} = ReqPackage, From, #{pool_id := PoolId} = State) ->
%   % R = pools:call(PoolId, call_fun, ReqPackage),
%   R = erlang:apply(Mod, F, Params),
%   Reply = #reply{from = From, reply_code = 1004, reply_data = R},
%   self() ! {reply, Reply},
%   ok;
action(?CMD_CALL_FUN, Package, _State) -> 
  % #request{from = From, req_cmd = _Cmd, req_data = {Mod, F, Params}} = binary_to_term(Package),
  #{from := From, req := {Mod, F, Params}} = binary_to_term(Package),
  R = erlang:apply(Mod, F, Params),
  % Reply = #reply{from = From, reply_code = 1004, reply_data = R},
  % self() ! {reply, Reply},
  ?LOG({reply, R, glib:date_str()}),
  MsgBody = term_to_binary(#reply{from = From, reply_code = 1004, reply_data = R}),
  Reply = glib_pb:encode_Msg(?CMD_CALL_FUN_REPLY, MsgBody),
  self() ! {reply, Reply},
  ok;
% % action(call_fun, {Mod, F, Params} = ReqPackage, From, #{pool_id := PoolId} = State) ->
% %   R = pools:call_other(PoolId, call_fun, ReqPackage),
% %   Reply = #reply{from = From, reply_code = 1004, reply_data = R},
% %   self() ! {reply, Reply},
% %   ok;
action(?CMD_CALL_FUN_REPLY, Package, _State) ->
  #reply{from = From, reply_code = _Cmd, reply_data = Payload} = binary_to_term(Package),
  glib:safe_reply(From, Payload),
  ok;
action(?CMD_REGISTER, Package, _State) -> 
  #request{from = From, req_cmd = _Cmd, req_data = RegisterConfig} = binary_to_term(Package),
  ?LOG({register_gw, RegisterConfig, From, self()}),
  #{cluster_id := ClusterId,node_id := NodeId,size := Size, work_id := WorkId} = RegisterConfig,
  Node = sys_config:get_config(node, node_id),
  table_pools:add({ClusterId, NodeId, WorkId, Node}, Size, self(), ClusterId),
  pools:create_pool(ClusterId),
  {update_state, #{table_pools_id => {ClusterId, NodeId, WorkId}, pool_id => ClusterId}};

% action(register_gw, RegisterConfig, From, _State) ->
%   ?LOG({register_gw, RegisterConfig, From, self()}),
%   #{cluster_id := ClusterId,node_id := NodeId,size := Size, work_id := WorkId} = RegisterConfig,
%   Node = sys_config:get_config(node, node_id),
%   table_pools:add({ClusterId, NodeId, WorkId, Node}, Size, self(), ClusterId),
%   pools:create_pool(ClusterId),
%   {update_state, #{table_pools_id => {ClusterId, NodeId, WorkId}, pool_id => ClusterId}};
action(?CMD_PING, _Package, _State) ->
  ok;
action(Cmd, Package, _State) -> 
  ?LOG({Cmd, Package}),
  ok.

% action(pub, {Cmd, Req}, From, #{pool_id := PoolId} = State) ->
% %%  ?LOG({pub, Req, From, State}),
%   pools:cast_other(PoolId, Cmd, Req),
%   ok;

% action(send, Req, From, State) ->
%   ?LOG({send, Req, From, State}),
%   ok;


% action(Cmd, ReqPackage, From, State) ->
%   ?LOG({Cmd, ReqPackage, From, State}),
%   ok.




