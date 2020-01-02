%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2019, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 31. Dec 2019 8:07 PM
%%%-------------------------------------------------------------------
-module(wsc_common_call_actor).
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
init([[WsAddr|_]|_]) ->
%%  ?LOG(WsAddr),
  % erlang:send_after(?TIMEOUT, self(), check_state), %

  % {ok, Pid} = go_ws_actor:start_link(1),

  % {ok, #{ws_pid => Pid}}.
  {ok, #{wsc_send_actor_pid => false, ws_addr => WsAddr}}.
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

handle_call({call, Cmd, ReqPackage}, From, #{wsc_send_actor_pid := Pid} = State) ->
  % Key = base64:encode(term_to_binary(From)),
  % Package = glib_pb:encode_RpcPackage(Key, Cmd, ReqPackage),
  % Package = term_to_binary({Key, Cmd, ReqPackage}),
  % Package = term_to_binary({From, Cmd, ReqPackage}),

  % Package = term_to_binary(#{from => From, cmd => Cmd, req => ReqPackage}),
  % Opts1 = #server_opts{port=80}.
  % -record(request, {
  % 	from,
  % 	req_cmd,
  % 	req_data
  % }).
  Package = term_to_binary(#request{from = From, req_cmd = Cmd, req_data = ReqPackage}),

  case erlang:is_pid(Pid) andalso glib:is_pid_alive(Pid) of
    true ->
      Pid ! {send, Package},
      {noreply, State};
    _ ->
      case wsc_send_actor:start_link(1) of
        {ok, NewPid} ->
          NewPid ! {send, Package},
          {noreply, #{wsc_send_actor_pid => NewPid}};
        _ ->
          ?WRITE_LOG("link_exception", {call, Cmd, ReqPackage}),
          Reply = {false, wsc_send_actor_exception},
          {reply, Reply, State}
      end
  end;
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
handle_cast({send, Cmd, ReqPackage}, #{wsc_send_actor_pid := Pid} = State) ->
  % ?LOG({send, Cmd, ReqPackage}),
  Package = term_to_binary(#request{from = null, req_cmd = Cmd, req_data = ReqPackage}),
  case erlang:is_pid(Pid) andalso glib:is_pid_alive(Pid) of
    true ->
      Pid ! {send, Package},
      {noreply, State};
    _ ->
      case wsc_send_actor:start_link(1) of
        {ok, NewPid} ->
          NewPid ! {send, Package},
          {noreply, #{wsc_send_actor_pid => NewPid}};
        Any ->
          ?WRITE_LOG("link_exception", {Any, cast, Package}),
          {noreply, State}
      end
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
% handle_info(check_state, #{ws_pid := Pid} = State) ->
% 	% ?LOG({info, Info}),
% 	% {stop, normal, gs_tcp_state}.
% 	erlang:send_after(?TIMEOUT, self(), check_state), %
% 	case erlang:is_pid(Pid) andalso glib:is_pid_alive(Pid) of
% 		true ->
% 			{noreply, State};
% 		_ ->
% 			case go_ws_actor:start_link(1) of
% 				{ok, NewPid} ->
% 					{noreply, #{ws_pid => NewPid}};
% 				_ ->
% 					{noreply, State}
% 			end
% 	end;
handle_info(Info, State) ->
  ?LOG({info, Info}),
%%	% {stop, normal, gs_tcp_state}.
  {noreply, State}.


% --------------------------------------------------------------------
% Function: terminate/2
% Description: Shutdown the server
% Returns: any (ignored by gen_server)
% --------------------------------------------------------------------
terminate(_Reason, _State) ->
  % ?LOG(closed),
  ok.

% --------------------------------------------------------------------
% Func: code_change/3
% Purpose: Convert process gs_tcp_state when code is changed
% Returns: {ok, Newgs_tcp_state}
% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


% priv







