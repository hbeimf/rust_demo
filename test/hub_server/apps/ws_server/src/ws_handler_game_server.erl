-module(ws_handler_game_server).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).
% -export([select/0, select/1]).


-include("log.hrl").
% -include_lib("stdlib/include/qlc.hrl").


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
	?LOG({"binary recv: ", Package}),
	% R = glibpack:unpackage(Package),
	% ?LOG({unpackage,  R}),
	 
	{ok, Req, State};
websocket_handle(Data, Req, State) ->
	?LOG({"XXy", Data}),
	{ok, Req, State}.

% websocket_info({broadcast, Msg}, Req, {_, Uid} = State) ->
% 	?LOG({broadcast, Msg}),
% 	{reply, {text, << "That's what she said! ", Msg/binary >>}, Req, State};
websocket_info({timeout, _Ref, Msg}, Req, State) ->
	% erlang:start_timer(1000, self(), <<"How' you doin'?">>),
	{reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
	{ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
	ok.
