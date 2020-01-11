%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Jan 2020 8:38 PM
%%%-------------------------------------------------------------------
-module(pools_work_actor).
-author("mm").

-behaviour(gen_server).
% --------------------------------------------------------------------
% Include files
% --------------------------------------------------------------------
% -include("log.hrl").
% -include("msg_proto.hrl").

% -record(state, {
% 	socket,
% 	transport,
% 	ip,
% 	port,
% 	data,
% 	call_pid
% }).

-define(TIMER_SECONDS, 30000).  %
-define(TIMEOUT, 1000).

% --------------------------------------------------------------------
% External exports
% --------------------------------------------------------------------
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include_lib("sys_log/include/write_log.hrl").
-include_lib("glib/include/rr.hrl").
-include_lib("glib/include/log.hrl").
% --------------------------------------------------------------------
% External API
% --------------------------------------------------------------------
% -export([send/0, send/1, call_req/2]).
% -export([call_req/2]).

% call_req(Pid, Package) ->
% 	gen_server:call(Pid, {call, Package}, ?TIMEOUT).

% start_link(ServerID, ServerType, ServerURI, GwcURI, Max) ->
% 	?LOG({ServerID, ServerType, ServerURI, GwcURI, Max}),
%     gen_server:start_link({local, ?MODULE}, ?MODULE, [ServerID, ServerType, ServerURI, GwcURI, Max], []).


start_link(Params) ->
  gen_server:start_link(?MODULE, [Params], []).


% --------------------------------------------------------------------
% Function: init/1
% Description: Initiates the server
% Returns: {ok, gs_tcp_state}          |
%          {ok, gs_tcp_state, Timeout} |
%          ignore               |
%          {stop, Reason}
% --------------------------------------------------------------------
init([[{PoolId}|_]|_]) ->
  ?WRITE_LOG("call_actor", {start, PoolId, self()}),
%%  ?LOG(WsAddr),
  % erlang:send_after(?TIMEOUT, self(), check_state), %

  % {ok, Pid} = go_ws_actor:start_link(1),

  % {ok, #{ws_pid => Pid}}.
  Pids = pools:get_pids(PoolId),
%%  ?LOG(Pids),

  {ok, #{pids => Pids, pool_id => PoolId}}.
% --------------------------------------------------------------------
% Function: handle_call/3
% Description: Handling call messages
% Returns: {reply, Reply, gs_tcp_state}          |
%          {reply, Reply, gs_tcp_state, Timeout} |
%          {noreply, gs_tcp_state}               |
%          {noreply, gs_tcp_state, Timeout}      |
%          {stop, Reason, Reply, gs_tcp_state}   | (terminate/2 is called)
%          {stop, Reason, gs_tcp_state}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_call({call, Cmd, ReqPackage}, _From, #{pids := [], pool_id := _PoolId} = State) ->
  ?WRITE_LOG("no_link_exception", {call, Cmd, ReqPackage}),
  Reply = false,
  {reply, Reply, State};
handle_call({call, Cmd, ReqPackage}, From, #{pids := Pids, pool_id := _PoolId} = State) ->
  % [Pid|_] = glib:shuffle_list(Pids),
  [Pid|OtherPid] = Pids,
  State1 = new_state(Pid, OtherPid, State),
  
  Package = term_to_binary(#request{from = From, req_cmd = Cmd, req_data = ReqPackage}),

  case erlang:is_pid(Pid) andalso glib:is_pid_alive(Pid) of
    true ->
      Pid ! {send, Package},
      {noreply, State1};
    _ ->
      ?WRITE_LOG("link3_exception", {call, Cmd, ReqPackage}),
      Reply = false,
      {reply, Reply, State}
  end;
handle_call(get_send_pid, _From, #{pids := Pids} = State) ->
%%  Reply = {send_pid, Pid},
  {reply, Pids, State};
handle_call(_Request, _From, State) ->
  Reply = ok,
  {reply, Reply, State}.


% --------------------------------------------------------------------
% Function: handle_cast/2
% Description: Handling cast messages
% Returns: {noreply, gs_tcp_state}          |
%          {noreply, gs_tcp_state, Timeout} |
%          {stop, Reason, gs_tcp_state}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_cast({send, Cmd, ReqPackage}, #{pids := [], pool_id := PoolId} = State) ->
  ?WRITE_LOG("send_no_link_exception", {call, Cmd, ReqPackage, PoolId}),
  {noreply, State};
handle_cast({send, Cmd, ReqPackage}, #{pids := Pids, pool_id := _PoolId} = State) ->
  % [Pid|_] = glib:shuffle_list(Pids),
  [Pid|OtherPid] = Pids,
  State1 = new_state(Pid, OtherPid, State),
  Package = term_to_binary(#request{from = null, req_cmd = Cmd, req_data = ReqPackage}),
  case erlang:is_pid(Pid) andalso glib:is_pid_alive(Pid) of
    true ->
      Pid ! {send, Package},
      {noreply, State1};
    _ ->
      ?WRITE_LOG("link2_exception", { cast, Cmd, Package}),
      {noreply, State}
  end;
handle_cast(Msg, State) ->
  ?LOG(Msg),
  {noreply, State}.

% --------------------------------------------------------------------
% Function: handle_info/2
% Description: Handling all non call/cast messages
% Returns: {noreply, gs_tcp_state}          |
%          {noreply, gs_tcp_state, Timeout} |
%          {stop, Reason, gs_tcp_state}            (terminate/2 is called)
% --------------------------------------------------------------------
% % erlang:send_after(?TIMEOUT, self(), check_state), %

handle_info({send, Package}, #{pids := [], pool_id := PoolId} = State) ->
  ?WRITE_LOG("send1_no_link_exception", {send, Package, PoolId}),
  {noreply, State};
handle_info({send, Package}, #{pids := [Pid|_Pids], pool_id := _PoolId} = State) ->
  case erlang:is_pid(Pid) andalso glib:is_pid_alive(Pid) of
    true ->
      Pid ! {send, Package},
      {noreply, State};
    _ ->
      ?WRITE_LOG("link1_exception", {send, Package}),
      {noreply, State}
  end;
%%handle_info({reconnect, Addr}, #{wsc_send_actor_pid := Pid, ws_addr := WsAddr, pool_id := PoolId} = State) ->
%%  ?LOG({info, Addr}),
%%  case Addr of
%%    WsAddr ->
%%      {noreply, State};
%%    _ ->
%%      case erlang:is_pid(Pid) andalso erlang:is_process_alive(Pid) of
%%        true ->
%%          Pid ! close,
%%          ok;
%%        _ ->
%%          ok
%%      end,
%%      case wsc_common_send_actor:start_link({PoolId, Addr}) of
%%        {ok, NewPid} ->
%%          {noreply, #{wsc_send_actor_pid => NewPid, ws_addr => Addr, pool_id => PoolId}};
%%        Any ->
%%          ?WRITE_LOG("reconnect_exception", {Any, Addr}),
%%          {noreply, State}
%%      end
%%  end;
%%	% {stop, normal, gs_tcp_state}.
%%  {noreply, State};
%%  {noreply, State};
handle_info(stop, State) ->
  ?LOG({stop, State, self()}),
  ?WRITE_LOG("call_actor_st", {stop, State}),
  {stop, normal, State};
handle_info(update, #{pool_id := PoolId} = State) ->
%%  ?LOG({update, State}),
%%  #{pids => Pids, pool_id => PoolId}
  Pids = pools:get_pids(PoolId),
  State1 = maps:update(pids, Pids, State),
  {noreply, State1};
handle_info(Info, State) ->
  ?WRITE_LOG("call_actor_stop_123", {stop, Info, State}),
  ?LOG({info, Info}),
%%	% {stop, normal, gs_tcp_state}.
  {noreply, State}.


% --------------------------------------------------------------------
% Function: terminate/2
% Description: Shutdown the server
% Returns: any (ignored by gen_server)
% --------------------------------------------------------------------
%%terminate(_Reason, #{wsc_send_actor_pid := Pid} = State) ->
%%  ?LOG({stop, State, Pid, self()}),
%%%%  case erlang:is_pid(Pid) andalso erlang:is_process_alive(Pid) of
%%%%    true ->
%%%%      Pid ! close,
%%%%      ok;
%%%%    _ ->
%%%%      ok
%%%%  end,
%%  ?WRITE_LOG("call_actor_stop", {close, State}),
%%  ok;
terminate(_Reason, State) ->
  ?WRITE_LOG("call_actor_stop1", {close, State}),
  ?LOG({stop, State}),
  ok.

% --------------------------------------------------------------------
% Func: code_change/3
% Purpose: Convert process gs_tcp_state when code is changed
% Returns: {ok, Newgs_tcp_state}
% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


% priv

new_state(Pid, OtherPid, State) -> 
  Pids = OtherPid ++ [Pid],
  maps:put(pids, Pids, State).





