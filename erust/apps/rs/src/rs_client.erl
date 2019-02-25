-module(rs_client).

-behaviour(gen_server).
% --------------------------------------------------------------------
% Include files
% --------------------------------------------------------------------
-include_lib("glib/include/log.hrl").
-include("msg_proto.hrl").

-record(state, { 
	socket,
	transport,
	ip,
	port,
	data,
	call_pid
}).

-define(TIMER_SECONDS, 30000).  % 
-define(TIMEOUT, 5000).

% --------------------------------------------------------------------
% External exports
% --------------------------------------------------------------------
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

% --------------------------------------------------------------------
% External API
% --------------------------------------------------------------------
% -export([send/0, send/1, call_req/2]).
-export([call_req/2]).

call_req(Pid, Package) ->
	gen_server:call(Pid, {call, Package}, ?TIMEOUT).

% send_test_msg() ->
%     TestMsg = #'TestMsg'{
%                         name = <<"jim green">>,
%                         nick_name = <<"nick_name123456">>,
%                         phone = <<"15912341234">> 
%                     },
%     TestMsgBin = msg_proto:encode_msg(TestMsg),
%     Package = glib:package(10001, TestMsgBin),
%     self() ! {send, Package},
%     ok.


% send_login() ->
%     Uid = glib:uid() rem 100000, 
%     Login = #'Login'{
%                         uid = Uid 
%                     },
%     TestMsgBin = msg_proto:encode_msg(Login),
%     Package = glib:package(10000, TestMsgBin),
%     self() ! {send, Package},
%     ok.

% start_link(ServerID, ServerType, ServerURI, GwcURI, Max) ->
% 	?LOG({ServerID, ServerType, ServerURI, GwcURI, Max}),
%     gen_server:start_link({local, ?MODULE}, ?MODULE, [ServerID, ServerType, ServerURI, GwcURI, Max], []).


start_link(Index) ->
	% ?LOG({ServerID, ServerType, ServerURI, GwcURI, Max}),
	% ?LOG({start, tcp_client}),
	gen_server:start_link(?MODULE, [Index], []).


% --------------------------------------------------------------------
% Function: init/1
% Description: Initiates the server
% Returns: {ok, gs_tcp_state}          |
%          {ok, gs_tcp_state, Timeout} |
%          ignore               |
%          {stop, Reason}
% --------------------------------------------------------------------
init([_Index]) ->

	% ?LOG({ServerID, ServerType, ServerURI, GwcURI, Max}),
	% {Ip, Port} = rconf:read_config(hub_server),
	Ip = "127.0.0.1",
	Port = 12345,
	% ?LOG({Ip, Port}),
	case ranch_tcp:connect(Ip, Port,[],3000) of
		{ok,Socket} ->
        			ok = ranch_tcp:setopts(Socket, [{active, once}]),
			% erlang:start_timer(1000, self(), {regist}),
			% self() ! {timeout, <<"Heartbeat!">>, <<"Heartbeat!">>},
			% erlang:start_timer(?TIMER_SECONDS, self(), <<"Heartbeat!">>),
			?LOG({connect, Ip, Port}),

			% send_login(),
			% send_test_msg(),
			
			State = #state{socket = Socket, transport = ranch_tcp, data = <<>>, ip = Ip, port = Port, call_pid=undefined},
			{ok,  State};
		{error,econnrefused} -> 
			erlang:start_timer(3000, self(), {reconnect,{Ip,Port}}),
			State = #state{socket = undefined, transport = ranch_tcp, data = <<>>, ip = Ip, port = Port, call_pid=undefined},
			{ok,State};
		% {error,econnrefused} -> 
		% 	?LOG(econnrefused),
		% 	{stop,econnrefused};
		{error,Reason} ->
			?LOG(error),
			{stop,Reason}
	end.

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
handle_call({call, Key, Package}, From, State=#state{socket=Socket, transport=_Transport, data=_LastPackage}) ->
	% ?LOG({call, Package}),
	ets_rpc_call_table:insert(Key, From),
	ranch_tcp:send(Socket, Package),
	{noreply, State#state{call_pid = From}};
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
handle_cast({send, Package}, State=#state{socket=Socket, transport=_Transport, data=_LastPackage}) ->
	ranch_tcp:send(Socket, Package),
	{noreply, State};
handle_cast(_Msg, State) ->
	{noreply, State}.		

% --------------------------------------------------------------------
% Function: handle_info/2
% Description: Handling all non call/cast messages
% Returns: {noreply, gs_tcp_state}          |
%          {noreply, gs_tcp_state, Timeout} |
%          {stop, Reason, gs_tcp_state}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_info({tcp, Socket, CurrentPackage}, State=#state{socket=Socket, transport=Transport, data=LastPackage}) -> 
	Transport:setopts(Socket, [{active, once}]),
	PackageBin = <<LastPackage/binary, CurrentPackage/binary>>,
	case parse_package(PackageBin, State) of
		{ok, waitmore, Bin} -> 
			{noreply, State#state{data = Bin}};
		_ -> 
			{stop, stop_noreason,State}
	end;
handle_info({send, Package}, State = #state{socket = Socket}) ->
	?LOG({send, Package}),
	ranch_tcp:send(Socket, Package),
	{noreply, State};
handle_info({timeout,_,{reconnect,{Ip,Port}}}, #state{transport = Transport} = State) ->
	% io:format("reconnect ip:[~p],port:[~p] ~n",[Ip,Port]),
	?LOG({reconnect, Ip, Port}),
	case Transport:connect(Ip,Port,[],3000) of
		{ok,Socket} ->
	        		ok = Transport:setopts(Socket, [{active, once}]),
			% erlang:start_timer(1000, self(), {regist}),
			{noreply,State#state{socket = Socket}};
		{error, _Reason} ->
			% io:format("==============Res:[~p]~n",[Reason]),
			erlang:start_timer(3000, self(), {reconnect,{Ip,Port}}),
			{noreply, State}
	end;
handle_info({tcp_closed, _Socket}, #state{ip = Ip, port = Port} = State) ->
	% io:format("~p:~p  tcp closed  !!!!!! ~n~n", [?MODULE, ?LINE]),
	% {stop, normal, gs_tcp_state};
	erlang:start_timer(3000, self(), {reconnect,{Ip,Port}}),
	{noreply, State#state{socket = undefined ,data = <<>>}};
	% {stop, tcp_closed,State};
handle_info({tcp_error, _, _Reason}, #state{ip = Ip, port = Port} = State) ->
	erlang:start_timer(3000, self(), {reconnect,{Ip,Port}}),
	{noreply, State#state{socket = undefined ,data = <<>>}};
% 	% {stop, Reason, gs_tcp_state};
handle_info(timeout, State) ->
	% {stop, normal, gs_tcp_state};
	{noreply, State};
% handle_info({timeout, _Ref, _HeartBeat}, State = #gs_tcp_state{socket = Socket}) -> 
% 	?LOG({heartbeat}),
% 	HeartbeatReq = #'HeartbeatReq'{},
%     HeartbeatReqBin = gwc_proto:encode_msg(HeartbeatReq),
%     Package = glib:package(?CMD_GS_3, HeartbeatReqBin),
%     ranch_tcp:send(Socket, Package),
%     erlang:start_timer(?TIMER_SECONDS, self(), <<"Heartbeat!">>),
% 	{noreply, State};
handle_info(Info, State) -> 
	?LOG({info, Info}),
	% {stop, normal, gs_tcp_state}.
	{noreply, State}.


% --------------------------------------------------------------------
% Function: terminate/2
% Description: Shutdown the server
% Returns: any (ignored by gen_server)
% --------------------------------------------------------------------
terminate(_Reason, _State) ->
	?LOG(closed),
	ok.

% --------------------------------------------------------------------
% Func: code_change/3
% Purpose: Convert process gs_tcp_state when code is changed
% Returns: {ok, Newgs_tcp_state}
% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.


% priv

parse_package(Bin, State) ->
    % ?LOG({bin, Bin}),
    case glib:unpackage(Bin) of
        {ok, waitmore}  -> {ok, waitmore, Bin};
        {ok, {Cmd, DataBin},LefBin} ->
            action(Cmd, DataBin, State),
            parse_package(LefBin, State);
        _ ->
            error       
    end.

 action(10008, DataBin, _State = #state{call_pid = _CallFrom}) ->

 	#'RpcPackage'{key = Key, 'payload' = Payload} = msg_proto:decode_msg(DataBin,'RpcPackage'),


 	{ok, From} = ets_rpc_call_table:select(Key),
 	% ?LOG({Key, Payload, From}),

 	ets_rpc_call_table:delete(Key),

 	% ?LOG({Cmd, DataBin, State}),
 	
 	% ?LOG({Name, NickName, Phone}),

	% gen_server:reply(CallFrom, DataBin),
	safe_reply(From, Payload),

 	ok;
  action(Cmd, DataBin, _State) ->

 	% #'TestMsg'{name = Name, 'nick_name' = NickName,
 	%  phone= Phone} = msg_proto:decode_msg(DataBin,'TestMsg'),

 	% ?LOG({Cmd, DataBin, State}),
 	
 	% ?LOG({Name, NickName, Phone}),

	% gen_server:reply(CallFrom, DataBin),
	% safe_reply(CallFrom, DataBin),
	?LOG({ignore_package, Cmd, DataBin}),

 	ok.


safe_reply(undefined, _Value) ->
    ok;
% safe_reply(Pid, Value) when is_pid(Pid) ->
%     % ?LOG({safe_reply, Pid, Value}),
%     safe_send(Pid, {response, Value});
safe_reply(From, Value) ->
    % ?LOG({safe_reply, From, Value}),
    gen_server:reply(From, Value).

% safe_send(Pid, Value) ->
%     try erlang:send(Pid, Value)
%     catch
%         Err:Reason ->
%             error_logger:info_msg("eredis: Failed to send message to ~p with reason ~p~n", [Pid, {Err, Reason}])
%     end.