-module(go_ws_actor).

-behaviour(websocket_client_handler).

% -define(ETS_OPTS,[set, public ,named_table , {keypos,2}, {heir,none}, {write_concurrency,true}, {read_concurrency,false}]).
% -define(WS_CONTROL_CENTER, control_center_handler_client).


% -record(control_center_handler_client, {
%     key,
%     val
% }).

-export([
         start_link/1,
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
% -include_lib("ws_server/include/log.hrl").

% % 进程状态
% -record(state, { 
%     data
%     }).

% % control_center_handler_client:send().
% send() ->
% 	Package = glibpack:package(1, <<"hello world!">>),
% 	send(Package).


% % control_center_handler_client:send(<<"test send">>).
% send(Package) ->
%     % case ets:match_object(?WS_CONTROL_CENTER, #control_center_handler_client{key = key(), _='_'}) of
%     %     [{?WS_CONTROL_CENTER, _Key, Pid}] -> 
%     %         Pid ! {binary, Package},
%     %         ok;
%     %     [] -> ok
%     % end, 
%     % ok.
%     control_monitor:send(Package).

% connect() ->
%     connect_control_center().

% connect_control_center() -> 
%     ets:new(?WS_CONTROL_CENTER, ?ETS_OPTS),
%     {ok, Pid} = start_link(key()),
%     ets:insert(?WS_CONTROL_CENTER, #control_center_handler_client{key=key(), val=Pid}),
%     %%　上报网关信息
%     GatewayLogin = #'Gateway'{
%                         gateway_id = 1,
%                         ws_addr = <<"ws://localhost:7788/websocket">>
%                     },

%     PbBin = gateway_proto:encode_msg(GatewayLogin),
%     Package = glib:package(?GATEWAY_CMD_REPORT, PbBin),

%     send(Package),

%     ok.

% key() -> 
%     <<"control_center_handler_client">>.

start_link(Index) ->
    Host = "ws://localhost:8000/ws",
    websocket_client:start_link(Host, ?MODULE, [Index]).

    

init([_Index], _ConnState) ->
    % websocket_client:cast(self(), {text, <<"message 1">>}),
    % io:format("client pid: ~p ~n", [self()]),
    % State = #state{data= <<>>},
    State = #{},
    {ok, State}.

% websocket_handle({pong, _}, _ConnState, State) ->
%     {ok, State};
% websocket_handle({text, Msg}, _ConnState, 5) ->
%     io:format("Received msg ~p~n", [Msg]),
%     {close, <<>>, "done"};

websocket_handle({binary, CurrentPackage}, _ConnState, State) ->
	% io:format("Client received binary here ~p~n", [Bin]),
    % ?LOG({binary, Bin}),
    % ?LOG({"binary recv: ", CurrentPackage}),
    % PackageBin = <<LastPackage/binary, CurrentPackage/binary>>,
    % case parse_package_from_gwc:parse_package(PackageBin, State) of 
    %     {ok, waitmore, NextBin} -> 
    %         {ok, State#state{data = NextBin}};
    %     _ -> 
    %         {close, <<>>, "done"}
    % end;
    {ok, State};
websocket_handle(Msg, _ConnState, State) ->
    % ?LOG({msg, Msg}),
    % io:format("Client ~p received msg:~n~p~n", [State, Msg]),
    % timer:sleep(1000),
    % BinInt = list_to_binary(integer_to_list(State)),
    % {reply, {text, <<"hello, this is message #", BinInt/binary >>}, State + 1}.
    {ok, State}.


websocket_info(close, _ConnState, _State) ->
    % ?LOG({close}),
	{close, <<>>, "done"};
websocket_info({text, Txt}, _ConnState, State) ->
    % ?LOG({text, Txt}),
	{reply, {text, Txt}, State};
websocket_info({send, Bin}, _ConnState, State) ->
    % ?LOG({binary, Bin}),
	{reply, {binary, Bin}, State}.

websocket_terminate(_Reason, _ConnState, _State) ->
    % io:format("~nClient closed in state ~p wih reason ~p~n", [State, Reason]),
    % ?LOG({ws_terminate}),
    ok.
