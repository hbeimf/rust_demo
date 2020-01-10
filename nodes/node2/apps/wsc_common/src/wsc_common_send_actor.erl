%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2020 10:16 AM
%%%-------------------------------------------------------------------
-module(wsc_common_send_actor).
-author("mm").

-behaviour(websocket_client_handler).

-include_lib("glib/include/log.hrl").
-include_lib("glib/include/rr.hrl").
-include_lib("sys_log/include/write_log.hrl").

-export([
  start_link/1,
  init/2,
  websocket_handle/3,
  websocket_info/3,
  websocket_terminate/3
]).



start_link({PoolId, WsAddr, CallBack, SupPid}) ->
  % Host = "ws://localhost:5678/ws",
%%  Host = sys_config:get_config(http, ws),
  websocket_client:start_link(WsAddr, ?MODULE, [{PoolId, WsAddr, CallBack, SupPid}]).



init([{PoolId, WsAddr, CallBack, SupPid} | _], _ConnState) ->
  ?WRITE_LOG("send_actor", {start, PoolId, WsAddr}),
  State = #{pool_id => PoolId, ws_addr => WsAddr, call_back => CallBack, sup_pid => SupPid},
  {ok, State}.

% websocket_handle({pong, _}, _ConnState, State) ->
%     {ok, State};
% websocket_handle({text, Msg}, _ConnState, 5) ->
%     io:format("Received msg ~p~n", [Msg]),
%     {close, <<>>, "done"};

websocket_handle({binary, CurrentPackage}, _ConnState, #{call_back := CallBack} = State) ->
  case binary_to_term(CurrentPackage) of
    #reply{from = From, reply_code = _Cmd, reply_data = Payload} ->
      safe_reply(From, Payload),
      ok;
    _Any ->
%%      ?LOG(Any),
      CallBack:action(CurrentPackage),
      ok
  end,
  {ok, State};
websocket_handle(Msg, _ConnState, State) ->
  ?LOG({msg, Msg}),
  % io:format("Client ~p received msg:~n~p~n", [State, Msg]),
  % timer:sleep(1000),
  % BinInt = list_to_binary(integer_to_list(State)),
  % {reply, {text, <<"hello, this is message #", BinInt/binary >>}, State + 1}.
  {ok, State}.

websocket_info({reply, Term}, _ConnState, State) ->
  % ?LOG({reply, Bin}),
  {reply, {binary, term_to_binary(Term)}, State};
websocket_info({send, Bin}, _ConnState, State) ->
  % ?LOG({send, Bin}),
  {reply, {binary, Bin}, State};
websocket_info(close, _ConnState, _State) ->
  % ?LOG({close}),
  {close, <<>>, "done"};
websocket_info({text, Txt}, _ConnState, State) ->
  % ?LOG({text, Txt}),
  {reply, {text, Txt}, State}.

websocket_terminate(_Reason, _ConnState, #{sup_pid := SupPid} = State) ->
  case erlang:is_pid(SupPid) andalso erlang:is_process_alive(SupPid) of
    true ->
      SupPid ! link_closed,
      ok;
    _ ->
      ok
  end,
%%  ?WRITE_LOG("wsc_common_link_closed", {close, State}),
  ok;
websocket_terminate(_Reason, _ConnState, State) ->
  % io:format("~nClient closed in state ~p wih reason ~p~n", [State, Reason]),
  % ?LOG({ws_terminate}),
%%  ?WRITE_LOG("wsc_close", {State}),
  ?WRITE_LOG("send_actor_close", {close, State}),
  ok.

safe_reply(null, _Value) ->
  ok;
safe_reply(undefined, _Value) ->
  ok;
safe_reply(From, Value) ->
  gen_server:reply(From, Value).
