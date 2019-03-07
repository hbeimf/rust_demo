-module(ws_handler).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).
% -export([select/0, select/1]).


% -include("table.hrl").
% -include_lib("stdlib/include/qlc.hrl").
% -define(TABLE, client_list).
-define(LOG(X), io:format("~n==========log========{~p,~p}==============~n~p~n", [?MODULE,?LINE,X])).
% -define(LOG(X), true).



init({tcp, http}, _Req, _Opts) ->
	{upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
	% erlang:start_timer(1000, self(), <<"Hello!">>),
	% Uid = uid(),
	% ?LOG({login, Uid}),
	% add(Uid, self()),
	State = [],
	{ok, Req, State}.

websocket_handle({text, Msg}, Req, State) ->
	?LOG({Msg}),
	% Clients = select(Uid),
	% ?LOG(Clients),
	% broadcast(Clients, Msg),
	{ok, Req, State};
	% {reply, {text, << "That's what she said! ", Msg/binary >>}, Req, State};
websocket_handle(_Data, Req, State) ->
	?LOG("XX"),
	{ok, Req, State}.

websocket_info({broadcast, Msg}, Req, State) ->
	?LOG({broadcast, Msg}),
	{reply, {text, << "That's what she said! ", Msg/binary >>}, Req, State};
websocket_info({timeout, _Ref, Msg}, Req, State) ->
	% erlang:start_timer(1000, self(), <<"How' you doin'?">>),
	{reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
	{ok, Req, State}.

websocket_terminate(_Reason, _Req, _State) ->
	ok.
