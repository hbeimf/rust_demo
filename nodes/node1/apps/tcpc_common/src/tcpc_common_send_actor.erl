%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2020 6:44 PM
%%%-------------------------------------------------------------------
-module(tcpc_common_send_actor).
-author("mm").

-behaviour(gen_server).
% --------------------------------------------------------------------
% Include files
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% External exports
% --------------------------------------------------------------------
-export([]).

% gen_server callbacks
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
% -export([request/2]).

% -record(ac_state, {}).
% -record(ac_state, {
% 	socket,
% 	transport,
% 	data,
% 	ip,
% 	port}).

% --------------------------------------------------------------------
% External API
% --------------------------------------------------------------------
% -export([ping/0, request/2]).

-define(TIMEOUT, 5000).

-define(TIMEER_HEARTBEAT, 60000).

-include_lib("glib/include/log.hrl").
-include_lib("glib/include/rr.hrl").
-include_lib("glib/include/cmd.hrl").


% -include("ac_state.hrl").
% -include("cmd_ac.hrl").

-define(TIMER_SECONDS, 500).  %

-include_lib("sys_log/include/write_log.hrl").

ping() ->
  ReqPackage = term_to_binary(#request{from = null, req_cmd = ?CMD_1000, req_data = ping}),
  glib:package(?CMD_1000, ReqPackage).

start_link(Params) ->
  gen_server:start_link(?MODULE, [Params], []).


% --------------------------------------------------------------------
% Function: init/1
% Description: Initiates the server
% Returns: {ok, ac_state}          |
%          {ok, ac_state, Timeout} |
%          ignore               |
%          {stop, Reason}
% --------------------------------------------------------------------
init([_Params]) ->
  % [Ip, Port|_] = Params,
  Ip = sys_config:get_config(tcp, host),
  Port = sys_config:get_config(tcp, port),
  % Ip = sys_config:get_config(account_service, server),
  % Port = sys_config:get_config(account_service, tcp_port),
  case ranch_tcp:connect(Ip, Port,[],3000) of
    {ok,Socket} ->
      % ?LOG(connect_ok),
      ok = ranch_tcp:setopts(Socket, [{active, once}]),
      PingPackage = ping(),
      self() ! {send, PingPackage},

      erlang:start_timer(?TIMEER_HEARTBEAT, self(), ping),
      State = #tcpc_state{socket = Socket, transport = ranch_tcp, data = <<>>, ip = Ip, port = Port},
      {ok,  State};
    % {error,econnrefused} ->
    % 	?WRITE_LOG("tcpc-exception", {error,econnrefused}),
    % 	?LOG({error,econnrefused}),
    % 	erlang:start_timer(?TIMER_SECONDS, self(), {reconnect,{Ip,Port}}),
    % 	State = #tcpc_state{socket = econnrefused, transport = ranch_tcp, data = <<>>,ip = Ip, port = Port},
    % 	{ok,State};
    % {error,Reason} ->
    % 	?LOG({error,Reason}),
    % 	?WRITE_LOG("tcpc-exception", {error,Reason}),
    % 	erlang:start_timer(?TIMER_SECONDS, self(), {reconnect,{Ip,Port}}),
    % 	State = #tcpc_state{socket = error, transport = ranch_tcp, data = <<>>,ip = Ip, port = Port},
    % 	{ok,State};
    % _ ->
    % 	% ?LOG({error, reconnect}),
    % 	?WRITE_LOG("tcpc-exception", {error,reconnect}),
    % 	erlang:start_timer(?TIMER_SECONDS, self(), {reconnect,{Ip,Port}}),
    % 	State = #tcpc_state{socket = error, transport = ranch_tcp, data = <<>>,ip = Ip, port = Port},
    % 	{ok,State}
    Any ->
      ?WRITE_LOG("tcpc-exception", {error,Any}),
      {stop, normal}
  end.



% --------------------------------------------------------------------
% Function: handle_call/3
% Description: Handling call messages
% Returns: {reply, Reply, ac_state}          |
%          {reply, Reply, ac_state, Timeout} |
%          {noreply, ac_state}               |
%          {noreply, ac_state, Timeout}      |
%          {stop, Reason, Reply, ac_state}   | (terminate/2 is called)
%          {stop, Reason, ac_state}            (terminate/2 is called)
% --------------------------------------------------------------------

% handle_call({doit, FromPid}, _From, ac_state) ->
%     io:format("doit  !! ============== ~n~n"),

%     lists:foreach(fun(_I) ->
%         FromPid ! {from_doit, <<"haha">>}
%     end, lists:seq(1, 100)),

%     {reply, [], ac_state};
% handle_call({request, Key, Package}, From, #tcpc_state{transport = _Transport,socket=Socket} = State) ->
% 	% ?LOG({call, Package}),
% 	% ?LOG(Key),
% 	case is_port(Socket) of
% 		true ->
% 			ets_ac:insert(Key, From),
% 			% ?LOG({Socket, is_port(Socket), State}),
% 			ranch_tcp:send(Socket, Package),
% 			{noreply, State};
% 		_ ->
% 			?WRITE_LOG("tcpc-exception", {error,socket_error}),
% 			Reply = {false, connect_error},
% 			{reply, Reply, State}
% 	end;
handle_call(_Request, _From, State) ->
  Reply = ok,
  {reply, Reply, State}.

% --------------------------------------------------------------------
% Function: handle_cast/2
% Description: Handling cast messages
% Returns: {noreply, ac_state}          |
%          {noreply, ac_state, Timeout} |
%          {stop, Reason, ac_state}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_cast({send, Package}, State=#tcpc_state{
  socket=Socket, transport=_Transport, data=_LastPackage}) ->
  ranch_tcp:send(Socket, Package),
  {noreply, State};
handle_cast(_Msg, State) ->
  {noreply, State}.

% --------------------------------------------------------------------
% Function: handle_info/2
% Description: Handling all non call/cast messages
% Returns: {noreply, ac_state}          |
%          {noreply, ac_state, Timeout} |
%          {stop, Reason, ac_state}            (terminate/2 is called)
% --------------------------------------------------------------------
% handle_info(_Info, ac_state) ->
%     {noreply, ac_state}.

handle_info({tcp, Socket, CurrentPackage}, State=#tcpc_state{socket=Socket, transport=Transport, data=LastPackage}) ->
  % when byte_size(Data) > 1 ->
  Transport:setopts(Socket, [{active, once}]),
  PackageBin = <<LastPackage/binary, CurrentPackage/binary>>,

  case parse_package(PackageBin, State) of
    {ok, waitmore, Bin} ->
      {noreply, State#tcpc_state{data = Bin}};
    Any ->
      % glib:write_log({?MODULE, ?LINE, stop_noreason, PackageBin, Any, ServerID, ServerType}),
      ?WRITE_LOG("tcpc-exception", {parse_package_error, Any}),
      {stop, normal,State}
  end;
handle_info({send, Package}, State = #tcpc_state{socket = Socket}) ->
  % ?LOG({send, Package}),
  ranch_tcp:send(Socket, Package),
  {noreply, State};
% handle_info({timeout,_,{reconnect,{Ip,Port}}}, #tcpc_state{transport = Transport} = State) ->
% 	?LOG({timeout, reconnect}),
% 	?WRITE_LOG("tcpc-exception", {reconnect,{Ip,Port}}),
% 	% io:format("reconnect ip:[~p],port:[~p] ~n",[Ip,Port]),
% 	case Transport:connect(Ip,Port,[],3000) of
% 		{ok,Socket} ->
% 			ok = Transport:setopts(Socket, [{active, once}]),
% 			PingPackage = ping(),
% 	        self() ! {send, PingPackage},
% 			% erlang:start_timer(1000, self(), {regist}),
% 			{noreply,State#tcpc_state{socket = Socket}};
% 		{error,Reason} ->
% 			% io:format("==============Res:[~p]~n",[Reason]),
% 			?WRITE_LOG("tcpc-exception", {reconnect-fail,{Ip,Port}, Reason}),
% 			erlang:start_timer(?TIMER_SECONDS, self(), {reconnect,{Ip,Port}}),
% 			{noreply, State}
% 	end;
handle_info({tcp_closed, _Socket}, #tcpc_state{ip = Ip, port = Port} = State) ->
  % ?LOG({tcp_closed}),
  % erlang:start_timer(?TIMER_SECONDS, self(), {reconnect,{Ip,Port}}),
  % {noreply, State#tcpc_state{socket = undefined ,data = <<>>}};
  ?WRITE_LOG("tcpc-exception", {tcp_closed,{Ip,Port}}),
  {stop, normal, State};
handle_info({tcp_error, _, _Reason}, #tcpc_state{ip = Ip, port = Port} = State) ->
  % erlang:start_timer(?TIMER_SECONDS, self(), {reconnect,{Ip,Port}}),
  % {noreply, State#tcpc_state{socket = undefined ,data = <<>>}};
  ?WRITE_LOG("tcpc-exception", {tcp_error,{Ip,Port}}),
  {stop, normal, State};
% handle_info({timeout,_, ping}, State) ->
% 	% ?LOG({info, ping}),
% 	PingPackage = ping(),
% 	self() ! {send, PingPackage},
% 	erlang:start_timer(?TIMEER_HEARTBEAT, self(), ping),
% 	% {stop, normal, ac_state}.
% 	{noreply, State};
handle_info(Info, State) ->
  ?LOG({info, Info}),
  % {stop, normal, ac_state}.
  {noreply, State}.


% --------------------------------------------------------------------
% Function: terminate/2
% Description: Shutdown the server
% Returns: any (ignored by gen_server)
% --------------------------------------------------------------------
terminate(_Reason, _State) ->
  ok.

% --------------------------------------------------------------------
% Func: code_change/3
% Purpose: Convert process ac_state when code is changed
% Returns: {ok, Newac_state}
% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.


%% ====================================================================
%% Internal functions
%% ====================================================================
parse_package(Bin, State) ->
  % case tcp_package:unpackage(Bin) of
  case glib:unpackage(Bin) of
    {ok, waitmore}  -> {ok, waitmore, Bin};
    {ok,{Cmd, ValueBin},LefBin} ->
      action(Cmd, ValueBin, State),
      % ?LOG({Type, ValueBin}),
      parse_package(LefBin, State);
    _ ->
      error
  end.

action(_Cmd, ValueBin, _State) ->
  % ?LOG({Cmd, ValueBin, State}),
  #reply{from = From, reply_code = _ReplyCode, reply_data = Payload} = binary_to_term(ValueBin),
  safe_reply(From, Payload),
  ok.

safe_reply(undefined, _Value) ->
  ok;
safe_reply(null, _Value) ->
  ok;
safe_reply(From, Value) ->
  gen_server:reply(From, Value).