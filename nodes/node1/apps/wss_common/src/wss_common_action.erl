%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Jan 2020 10:37 AM
%%%-------------------------------------------------------------------
-module(wss_common_action).
-author("mm").

-compile(export_all).

-define(TIMEOUT, 5000).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").
-include_lib("glib/include/rr.hrl").


action(Package) ->
  #request{from = From, req_cmd = Cmd, req_data = ReqPackage} = binary_to_term(Package),
  action(Cmd, ReqPackage, From),
  ok.


% -record(reply, {
% 	from,
%     reply_code,
%     reply_data
% }).
action(1000, _, From) ->
  Reply = #reply{from = From, reply_code = 1001, reply_data = pong},
  self() ! {reply, Reply},
  ok;
action(1003, {Mod, F, Params}, From) ->
%%  Reply = Mon:F(),
%%  ?LOG({Mod, F, Params}),
  R = erlang:apply(Mod, F, Params),
%%  ?LOG(R),
  Reply = #reply{from = From, reply_code = 1004, reply_data = R},
  self() ! {reply, Reply},
  ok;

action(register_gw, RegisterConfig, From) ->
  ?LOG({register_gw, RegisterConfig, From, self()}),
  #{cluster_id := ClusterId,node_id := NodeId,size := Size, work_id := WorkId} = RegisterConfig,
  table_cluster:add({ClusterId, WorkId}, NodeId, Size, WorkId, self()),
  pools:dynamic_start_pool(ClusterId),
  ok;

action(Cmd, ReqPackage, From) ->
  ?LOG({Cmd, ReqPackage, From}),
  ok.




