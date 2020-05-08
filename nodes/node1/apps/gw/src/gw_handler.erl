%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Jan 2020 11:47 AM
%%%-------------------------------------------------------------------
-module(gw_handler).
-author("mm").

-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).
% -export([select/0, select/1]).


% -include("log.hrl").
-include_lib("glib/include/log.hrl").
-include_lib("glib/include/rr.hrl").

init({tcp, http}, _Req, _Opts) ->
  {upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
  State = ok,
  {ok, Req, State}.

websocket_handle({binary, Package}, Req, State) ->
  % case binary_to_term(Package) of
  %   #reply{from = From, reply_code = _Cmd, reply_data = Payload} ->
  %     safe_reply(From, Payload),
  %     {ok, Req, State};
  %   _Any ->
      case gw_action:action(Package, State) of
        {update_state, NewState} ->
          {ok, Req, NewState};
        _ ->
%%          ?LOG(Any),
          {ok, Req, State}
      end;
  % end;
websocket_handle(Data, Req, State) ->
  ?LOG({"XXy", Data}),
  {ok, Req, State}.

websocket_info({reply, Reply}, Req, State) ->
  {reply, {binary, Reply}, Req, State};
websocket_info({send, Package}, Req, State) ->
  {reply, {binary, Package}, Req, State};

websocket_info({timeout, _Ref, Msg}, Req, State) ->
  {reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
  {ok, Req, State}.

websocket_terminate(_Reason, _Req, #{pool_id := PoolId, table_pools_id := Id} = State) ->
  ?LOG({close, State}),
  table_pools:delete(Id),
  pools:update(PoolId),
  ok;
websocket_terminate(_Reason, _Req, State) ->
  ?LOG({close, State}),
  ok.

% safe_reply(null, _Value) ->
%   ok;
% safe_reply(undefined, _Value) ->
%   ok;
% safe_reply(#{from :=From, pid := Pid}, Value)->
%   gen_server:reply(From, Value),
%   Pid ! close;
% safe_reply(From, Value) ->
%   gen_server:reply(From, Value).