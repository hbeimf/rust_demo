% handler_gs_tcp.erl

-module(handler_gs_tcp).

-behaviour(gen_server).
% --------------------------------------------------------------------
% Include files
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% External exports
% --------------------------------------------------------------------
-export([]).

% gen_server callbacks
-export([start_link/5]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

% -record(gs_tcp_state, {}).
% -record(gs_tcp_state, {
% 	socket, 
% 	transport, 
% 	data,
% 	ip,
% 	port}).

% --------------------------------------------------------------------
% External API
% --------------------------------------------------------------------
-export([send/0, send/1]).


-include_lib("ws_server/include/log.hrl").
-include("gs_tcp_state.hrl").
-include("gwc_proto.hrl").
-include("cmd_gs.hrl").

-define(TIMER_SECONDS, 30000).  % 


send() -> 
	Type = 1111, 
	Bin = <<"test send!!">>,
	P = tcp_package:package(Type, Bin),

	Type1 = 2222, 
	Bin1 = <<"test sendXX!!">>,
	P1 = tcp_package:package(Type1, Bin1),

	Type2 = 9999, 
	Bin2 = <<"test sendXX!!">>,
	P2 = tcp_package:package(Type2, Bin2),

	PP = <<P/binary, P1/binary, P2/binary>>,
	send(PP).


send(Package) -> 
	gen_server:cast(?MODULE, {send, Package}).

% doit(FromPid) ->
%     gen_server:cast(?MODULE, {doit, FromPid}).



% start_link(ServerID, ServerType, ServerURI, GwcURI, Max) ->
% 	?LOG({ServerID, ServerType, ServerURI, GwcURI, Max}),
%     gen_server:start_link({local, ?MODULE}, ?MODULE, [ServerID, ServerType, ServerURI, GwcURI, Max], []).


start_link(ServerID, ServerType, ServerURI, GwcURI, Max) ->
	?LOG({ServerID, ServerType, ServerURI, GwcURI, Max}),
    gen_server:start_link(?MODULE, [ServerID, ServerType, ServerURI, GwcURI, Max], []).


% --------------------------------------------------------------------
% Function: init/1
% Description: Initiates the server
% Returns: {ok, gs_tcp_state}          |
%          {ok, gs_tcp_state, Timeout} |
%          ignore               |
%          {stop, Reason}
% --------------------------------------------------------------------
init([ServerID, ServerType, ServerURI, GwcURI, Max]) ->

	?LOG({ServerID, ServerType, ServerURI, GwcURI, Max}),
	% {Ip, Port} = rconf:read_config(hub_server),
	% Ip = "127.0.0.1",
	% Port = "9966",
	{Ip, Port} = gs_call:get_ip_port(GwcURI),	
	?LOG({Ip, Port}),


	case ranch_tcp:connect(Ip, Port,[],3000) of
		{ok,Socket} ->
	        ok = ranch_tcp:setopts(Socket, [{active, once}]),
			% erlang:start_timer(1000, self(), {regist}),
			self() ! {timeout, <<"Heartbeat!">>, <<"Heartbeat!">>},
			erlang:start_timer(?TIMER_SECONDS, self(), <<"Heartbeat!">>),
			State = #gs_tcp_state{socket = Socket, transport = ranch_tcp, data = <<>>, ip = Ip, port = Port,
				server_id=ServerID, %%  游戏服id
				server_type=ServerType, %%  游戏服类型
				server_uri=ServerURI,  %%  客户端连游戏服地址
				gwc_uri=GwcURI, %% gwc连接游戏服地址
				max=Max %%   游戏服最多能容纳多少链接 
			},
			{ok,  State};
		% {error,econnrefused} -> 
		% 	erlang:start_timer(3000, self(), {reconnect,{Ip,Port}}),
		% 	State = #gs_tcp_state{socket = econnrefused, transport = ranch_tcp, data = <<>>,ip = Ip, port = Port,
		% 		server_id=ServerID, %%  游戏服id
		% 		server_type=ServerType, %%  游戏服类型
		% 		server_uri=ServerURI,  %%  客户端连游戏服地址
		% 		gwc_uri=GwcURI, %% gwc连接游戏服地址
		% 		max=Max %%   游戏服最多能容纳多少链接 
		% 	},
		% 	{ok,State};
		{error,econnrefused} -> 
			?LOG(econnrefused),
			{stop,econnrefused};
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

% handle_call({doit, FromPid}, _From, gs_tcp_state) ->
%     io:format("doit  !! ============== ~n~n"),

%     lists:foreach(fun(_I) ->
%         FromPid ! {from_doit, <<"haha">>}
%     end, lists:seq(1, 100)),

%     {reply, [], gs_tcp_state};
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
handle_cast({send, Package}, State=#gs_tcp_state{
		socket=Socket, transport=_Transport, data=_LastPackage}) ->
    % io:format("send cast !! ============== ~n~n"),
    % {ok, GoMBox} = application:get_env(go, go_mailbox),
    % io:format("message ~p!! ============== ~n~n", [GoMBox]),
    % gen_server:cast(GoMBox, {Msg, self()}),

    % P1 = tcp_package:package(Type, Bin),

    % P = <<P1/binary, P1/binary>>,
    % ranch_tcp:send(Socket, P),
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
% handle_info(_Info, gs_tcp_state) ->
%     {noreply, gs_tcp_state}.

handle_info({tcp, Socket, CurrentPackage}, State=#gs_tcp_state{
		socket=Socket, transport=Transport, data=LastPackage}) -> 
		% when byte_size(Data) > 1 ->
	Transport:setopts(Socket, [{active, once}]),
	PackageBin = <<LastPackage/binary, CurrentPackage/binary>>,

	case parse_package_from_gs:parse_package(PackageBin, State) of
		{ok, waitmore, Bin} -> 
			{noreply, State#gs_tcp_state{data = Bin}};
		_ -> 
			{stop, stop_noreason,State}
	end;
% handle_info({timeout,_,{regist}}, State=#gs_tcp_state{socket=Socket}) ->
% 	% 注册代理 
% 	Bin = client_package:regist_proxy(),
% 	ranch_tcp:send(Socket, Bin),
% 	% 同步客户信息
% 	sync_client(),
% 	{noreply, gs_tcp_state};

handle_info({send, Package}, State = #gs_tcp_state{socket = Socket}) ->
	ranch_tcp:send(Socket, Package),
	{noreply, State};
% handle_info({timeout,_,{reconnect,{Ip,Port}}}, #gs_tcp_state{transport = Transport} = State) ->
% 	io:format("reconnect ip:[~p],port:[~p] ~n",[Ip,Port]),
% 	case Transport:connect(Ip,Port,[],3000) of
% 		{ok,Socket} ->
% 	        ok = Transport:setopts(Socket, [{active, once}]),
% 			erlang:start_timer(1000, self(), {regist}),
% 			{noreply,State#gs_tcp_state{socket = Socket}};
% 		{error,Reason} ->
% 			io:format("==============Res:[~p]~n",[Reason]),
% 			erlang:start_timer(3000, self(), {reconnect,{Ip,Port}}),
% 			{noreply, State}
% 	end;
handle_info({tcp_closed, _Socket}, #gs_tcp_state{ip = _Ip, port = _Port} = State) ->
	io:format("~p:~p  tcp closed  !!!!!! ~n~n", [?MODULE, ?LINE]),
	% {stop, normal, gs_tcp_state};
	% erlang:start_timer(3000, self(), {reconnect,{Ip,Port}}),
	% {noreply, State#gs_tcp_state{socket = undefined ,data = <<>>}};
	{stop, tcp_closed,State};
% handle_info({tcp_error, _, _Reason}, #gs_tcp_state{ip = Ip, port = Port} = State) ->
% 	% erlang:start_timer(3000, self(), {reconnect,{Ip,Port}}),
% 	{noreply, State#gs_tcp_state{socket = undefined ,data = <<>>}};
% 	% {stop, Reason, gs_tcp_state};
handle_info(timeout, State) ->
	% {stop, normal, gs_tcp_state};
	{noreply, State};
handle_info({timeout, _Ref, _HeartBeat}, State = #gs_tcp_state{socket = Socket}) -> 
	?LOG({heartbeat}),
	HeartbeatReq = #'HeartbeatReq'{},
    HeartbeatReqBin = gwc_proto:encode_msg(HeartbeatReq),
    Package = glib:package(?CMD_GS_3, HeartbeatReqBin),
    ranch_tcp:send(Socket, Package),
    erlang:start_timer(?TIMER_SECONDS, self(), <<"Heartbeat!">>),
	{noreply, State};
handle_info(Info, State) -> 
	?LOG({info, Info}),
	% {stop, normal, gs_tcp_state}.
	{noreply, State}.


% --------------------------------------------------------------------
% Function: terminate/2
% Description: Shutdown the server
% Returns: any (ignored by gen_server)
% --------------------------------------------------------------------
terminate(_Reason, _State = #gs_tcp_state{server_id=ServerID, server_type=ServerType}) ->
	?LOG(closed),
    gw_call:send_gs_halt_msg(ServerID, ServerType),
    table_game_server_list:delete(ServerID),
    ok.

% --------------------------------------------------------------------
% Func: code_change/3
% Purpose: Convert process gs_tcp_state when code is changed
% Returns: {ok, Newgs_tcp_state}
% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


