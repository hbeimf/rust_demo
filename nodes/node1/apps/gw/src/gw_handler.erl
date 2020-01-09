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
  % erlang:start_timer(1000, self(), <<"Hello!">>),
  % uid=0,
  % islogin = false,
  % stype =0,
  % sid=0,
  % data
  % State = #state{uid = 0, islogin = false, stype = 0, sid = 0, data= <<>>},
  % State = #state_game_server{proxy_id = 0, data= <<>>},
  State = ok,
  {ok, Req, State}.

% websocket_handle({text, Msg}, Req, {_, Uid} = State) ->
% 	?LOG({Uid, Msg}),
% 	Clients = select(Uid),
% 	?LOG(Clients),
% 	broadcast(Clients, Msg),
% 	{ok, Req, State};
% {reply, {text, << "That's what she said! ", Msg/binary >>}, Req, State};


websocket_handle({binary, Package}, Req, State) ->
  % ?LOG({"binary recv: ", Package}),
  % R = glibpack:unpackage(Package),
  % ?LOG({unpackage,  R}),

%%  gw_action:action(Package),

  case binary_to_term(Package) of
    #reply{from = From, reply_code = _Cmd, reply_data = Payload} ->
      safe_reply(From, Payload),
      ok;
    Any ->
%%      ?LOG(Any),
      gw_action:action(Package),
      ok
  end,
  {ok, Req, State};
websocket_handle(Data, Req, State) ->
  ?LOG({"XXy", Data}),
  {ok, Req, State}.

% websocket_info({broadcast, Msg}, Req, {_, Uid} = State) ->
% 	?LOG({broadcast, Msg}),
% 	{reply, {text, << "That's what she said! ", Msg/binary >>}, Req, State};
websocket_info({reply, Reply}, Req, State) ->
  {reply, {binary, term_to_binary(Reply)}, Req, State};
websocket_info({send, Package}, Req, State) ->
  {reply, {binary, Package}, Req, State};

websocket_info({timeout, _Ref, Msg}, Req, State) ->
  % erlang:start_timer(1000, self(), <<"How' you doin'?">>),
  {reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
  {ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
  ok.

safe_reply(undefined, _Value) ->
  ok;
safe_reply(From, Value) ->
  gen_server:reply(From, Value).