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
-include_lib("glib/include/cmd.hrl").

-define(TIMEOUT, 2*60*1000).
% -define(TIMEOUT, 2*1000).


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
  process_flag(trap_exit, true),
  ?WRITE_LOG("send_actor", {start, PoolId, WsAddr}),
  State = #{pool_id => PoolId, ws_addr => WsAddr, call_back => CallBack, sup_pid => SupPid},
  erlang:start_timer(?TIMEOUT, self(), heart_beat),
  {ok, State}.

% websocket_handle({pong, _}, _ConnState, State) ->
%     {ok, State};
% websocket_handle({text, Msg}, _ConnState, 5) ->
%     io:format("Received msg ~p~n", [Msg]),
%     {close, <<>>, "done"};

websocket_handle({binary, CurrentPackage}, _ConnState, #{call_back := CallBack} = State) ->
%   case binary_to_term(CurrentPackage) of
%     #reply{from = From, reply_code = _Cmd, reply_data = Payload} ->
%       safe_reply(From, Payload),
%       % ?LOG({reply, From, Payload}),
%       ok;
%     _Any ->
% %%      ?LOG(Any),
%       CallBack:action(CurrentPackage),
%       ok
%   end,
  CallBack:action(CurrentPackage),
  {ok, State};
websocket_handle(Msg, _ConnState, State) ->
  ?LOG({msg, Msg}),
  % io:format("Client ~p received msg:~n~p~n", [State, Msg]),
  % timer:sleep(1000),
  % BinInt = list_to_binary(integer_to_list(State)),
  % {reply, {text, <<"hello, this is message #", BinInt/binary >>}, State + 1}.
  {ok, State}.

websocket_info({reply, Bin}, _ConnState, State) ->
  % ?LOG({reply, Bin}),
  % {reply, {binary, term_to_binary(Term)}, State};
  {reply, {binary, Bin}, State};
websocket_info({send, Bin}, _ConnState, State) ->
  % ?LOG({send, Bin}),
  {reply, {binary, Bin}, State};
websocket_info(close, _ConnState, _State) ->

  ?LOG({close}),
  {close, <<>>, "done"};
websocket_info({text, Txt}, _ConnState, State) ->
  % ?LOG({text, Txt}),
  {reply, {text, Txt}, State};


websocket_info({timeout, _Ref, heart_beat}, _ConnState, State) ->
  % ?LOG(heart_beat),
  erlang:start_timer(?TIMEOUT, self(), heart_beat),
  MsgBody = term_to_binary(#request{from = null, req_cmd = ping, req_data = hb}),
  % {ok, State};
  Bin = glib_pb:encode_Msg(?CMD_PING, MsgBody),
  {reply, {binary, Bin}, State};
websocket_info(Info, _ConnState, State) ->
  ?LOG(Info),
  {ok, State}.


websocket_terminate(_Reason, _ConnState, #{sup_pid := SupPid} = State) ->
  ?LOG(close1),
  case erlang:is_pid(SupPid) andalso erlang:is_process_alive(SupPid) of
    true ->
      ?LOG(close33),
%%      SupPid ! link_closed,
      ?LOG(close3),
      ok;
    _ ->
      ok
  end,
%%  ?WRITE_LOG("wsc_common_link_closed", {close, State}),
  ok;
websocket_terminate(_Reason, _ConnState, State) ->
  ?LOG(close2),
  % io:format("~nClient closed in state ~p wih reason ~p~n", [State, Reason]),
  % ?LOG({ws_terminate}),
%%  ?WRITE_LOG("wsc_close", {State}),
  ?WRITE_LOG("send_actor_close", {close, State}),
  ok.

% safe_reply(null, _Value) ->
%   ok;
% safe_reply(undefined, _Value) ->
%   ok;
% safe_reply(#{from := From, pid := Pid}, Value) ->
%   gen_server:reply(From, Value),
%   case erlang:is_pid(Pid) andalso glib:is_pid_alive(Pid) of 
%     true -> 
%       Pid ! close,
%       ok;
%       _ -> 
%       ok
%     end;
% safe_reply(From, Value) ->
%   gen_server:reply(From, Value).
