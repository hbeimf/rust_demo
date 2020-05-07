%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Jan 2020 12:37 PM
%%%-------------------------------------------------------------------
-module(gwc_action).
-author("mm").
-compile(export_all).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").
-include_lib("glib/include/rr.hrl").
-include_lib("glib/include/cmd.hrl").

action(Msg) ->
  {Action, Package} = glib_pb:decode_Msg(Msg),

  % #request{from = From, req_cmd = Cmd, req_data = ReqPackage} = binary_to_term(Package),
  % action(Cmd, ReqPackage, From),
  action(Action, Package),
  ok.


action(?CMD_CALL_FUN, Package) -> 
  #request{from = From, req_cmd = _Cmd, req_data = {Mod, F, Params}} = binary_to_term(Package),
  R = erlang:apply(Mod, F, Params),
  MsgBody = term_to_binary(#reply{from = From, reply_code = 1004, reply_data = R}),
  Bin = glib_pb:encode_Msg(?CMD_CALL_FUN_REPLY, MsgBody),
  self() ! {reply, Bin},
  ok;
action(Action, Package) -> 
  ?LOG({action, Action, Package}),
  ok.


% % -record(reply, {
% % 	from,
% %     reply_code,
% %     reply_data
% % }).
% action(ping, Req, From) ->
%   ?LOG({Req, From}),
%   case From of
%     null ->
%       ok;
%     _ ->
%       Reply = #reply{from = From, reply_code = 1001, reply_data = pong},
%       self() ! {reply, Reply},
%       ok
%   end,
%   ok;
% action(call_fun, {Mod, F, Params}, From) ->
% %%  Reply = Mon:F(),
%   ?LOG({Mod, F, Params, From}),
%   R = erlang:apply(Mod, F, Params),
% %%  ?LOG(R),
%   Reply = #reply{from = From, reply_code = 1004, reply_data = R},
%   self() ! {reply, Reply},
%   ok;

% action(Cmd, ReqPackage, From) ->
%   ?LOG({Cmd, ReqPackage, From, self()}),
%   ok.
