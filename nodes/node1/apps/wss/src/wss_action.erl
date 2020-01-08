-module(wss_action).
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

action(register_gw, {ClusterId, NodeId, Addr}, From) ->
  ?LOG({register_gw, {ClusterId, NodeId, Addr}, From}),
  wsc_common:dynamic_start_pool(ClusterId, Addr),
  ok;

action(Cmd, ReqPackage, From) ->
  ?LOG({Cmd, ReqPackage, From}),
  ok.



