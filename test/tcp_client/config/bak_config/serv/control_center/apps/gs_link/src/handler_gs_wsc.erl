% handler_gs_wsc.erl
-module(handler_gs_wsc).

-behaviour(websocket_client_handler).

% -define(ETS_OPTS,[set, public ,named_table , {keypos,2}, {heir,none}, {write_concurrency,true}, {read_concurrency,false}]).
% -define(WS_CONTROL_CENTER, control_center_handler_client).
% -record(control_center_handler_client, {
%     key,
%     val
% }).

-export([
         start_link/5,
         init/2,
         websocket_handle/3,
         websocket_info/3,
         websocket_terminate/3
        ]).


% -export([
%     connect/0,
%     connect_control_center/0,
%     send/1,
%     send/0
%     ]).

% -include("gateway_proto.hrl").
% -include("cmd_gateway.hrl").
-include_lib("ws_server/include/log.hrl").
-include("gs_wsc_state.hrl").
-include("gwc_proto.hrl").
-define(TIMER_SECONDS, 10000).  % 

start_link(ServerID, ServerType, ServerURI, GwcURI, Max) ->
    ?LOG({"connect gs", ServerID, ServerType, ServerURI, GwcURI, Max}),
    ?LOG(GwcURI),
    websocket_client:start_link(GwcURI, ?MODULE, [{ServerID, ServerType, ServerURI, GwcURI, Max}]).

init([{ServerID, ServerType, ServerURI, GwcURI, Max}|_], _ConnState) ->
    ?LOG({"connect gs init",  ServerID, ServerType, ServerURI, GwcURI, Max}),
    erlang:start_timer(?TIMER_SECONDS, self(), <<"Heartbeat!">>),
    State = #gs_wsc_state{
    			server_id=ServerID, %%  游戏服id
				server_type=ServerType, %%  游戏服类型
				server_uri=ServerURI,  %%  客户端连游戏服地址
				gwc_uri=GwcURI, %% gwc连接游戏服地址
				max=Max, %%   游戏服最多能容纳多少链接 
    			data= <<>>
    		},
    {ok, State}.

% websocket_handle({pong, _}, _ConnState, State) ->
%     {ok, State};
% websocket_handle({text, Msg}, _ConnState, 5) ->
%     io:format("Received msg ~p~n", [Msg]),
%     {close, <<>>, "done"};

websocket_handle({binary, CurrentPackage}, _ConnState, State= #gs_wsc_state{data= LastPackage}) ->
	% io:format("Client received binary here ~p~n", [Bin]),
    % ?LOG({binary, Bin}),
    ?LOG({"binary recv: ", CurrentPackage}),
    PackageBin = <<LastPackage/binary, CurrentPackage/binary>>,
    case parse_package_from_gs:parse_package(PackageBin, State) of 
        {ok, waitmore, NextBin} -> 
            {ok, State#gs_wsc_state{data = NextBin}};
        _ -> 
            {close, <<>>, "done"}
    end;
websocket_handle(Msg, _ConnState, State) ->
    ?LOG({msg, Msg}),
    % io:format("Client ~p received msg:~n~p~n", [State, Msg]),
    % timer:sleep(1000),
    % BinInt = list_to_binary(integer_to_list(State)),
    % {reply, {text, <<"hello, this is message #", BinInt/binary >>}, State + 1}.
    {ok, State}.

% websocket_info({timeout, _Ref, Msg}, Req, State) ->

websocket_info(close, _ConnState, _State) ->
    ?LOG({close}),
	{close, <<>>, "done"};
websocket_info({text, Txt}, _ConnState, State) ->
    ?LOG({text, Txt}),
	{reply, {text, Txt}, State};
websocket_info({send, Bin}, _ConnState, State) ->
    ?LOG({binary, Bin}),
	{reply, {binary, Bin}, State};
websocket_info({timeout, _Ref, Msg}, _ConnState, State) ->
    ?LOG({timeout, Msg}),
    HeartbeatReq = #'HeartbeatReq'{},
    HeartbeatReqBin = gwc_proto:encode_msg(HeartbeatReq),
    erlang:start_timer(?TIMER_SECONDS, self(), <<"Heartbeat!">>),
    {reply, {binary, HeartbeatReqBin}, State};
websocket_info(Msg, _ConnState, State) ->
    ?LOG({msg, Msg}),
    {ok, State}.



websocket_terminate(_Reason, _ConnState, _State= #gs_wsc_state{server_id=ServerID, server_type=ServerType}) ->
    % io:format("~nClient closed in state ~p wih reason ~p~n", [State, Reason]),
    ?LOG({ws_terminate}),
    %% 当游戏服连接断开时，必须通知网关让他放弃继续在这台节点上安排连接 
    gw_call:send_gs_halt_msg(ServerID, ServerType),
    ok.
