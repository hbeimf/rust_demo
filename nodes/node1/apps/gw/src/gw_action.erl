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


action(Package) ->
  #request{from = From, req_cmd = Cmd, req_data = ReqPackage} = binary_to_term(Package),
  action(Cmd, ReqPackage, From),
  ok.


% -record(reply, {
% 	from,
%     reply_code,
%     reply_data
% }).
action(cast_ping, Req, From) ->
  ?LOG({cast_ping, Req, From, glib:date_str()}),
  ok;
action(ping, _, From) ->
  Reply = #reply{from = From, reply_code = 1001, reply_data = pong},
  self() ! {reply, Reply},
  ok;
action(call_fun, {Mod, F, Params}, From) ->
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
  table_pools:add({ClusterId, NodeId, WorkId}, Size, self(), ClusterId),
  pools:create_pool(ClusterId),

  ok;

action(Cmd, ReqPackage, From) ->
  ?LOG({Cmd, ReqPackage, From}),
  ok.




