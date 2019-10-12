% gc.erl

-module(gc).

-behaviour(websocket_client_handler).

-export([
         start_link/0,
         init/2,
         websocket_handle/3,
         websocket_info/3,
         websocket_terminate/3
        ]).

% 进程状态
-record(state, { 
    data
    }).

-define(LOG1(X), io:format("~n==========log1========{~p,~p}==============~n~p~n", [?MODULE,?LINE,X])).
% -define(LOG1(X), true).

start_link() ->
    websocket_client:start_link("ws://localhost:9988/ws", ?MODULE, []).

init([], _ConnState) ->
    process_flag(trap_exit, true),
    State = #state{ data= <<>>},
    {ok, State}.

% websocket_handle({pong, _}, _ConnState, State) ->
%     {ok, State};
% websocket_handle({text, Msg}, _ConnState, 5) ->
%     io:format("Received msg ~p~n", [Msg]),
%     {close, <<>>, "done"};

% websocket_handle({binary, CurrentPackage}, _ConnState, State= #state{data= LastPackage}) ->
%     ?LOG({"binary recv: ", CurrentPackage}),
%     PackageBin = <<LastPackage/binary, CurrentPackage/binary>>,
%     case parse_package_from_gs:parse_package(PackageBin, State) of 
%         {ok, waitmore, NextBin} -> 
%             {ok, State#state{data = NextBin}};
%         _ -> 
%             {close, <<>>, "done"}
%     end;
	% {ok, State};

websocket_handle(Msg, _ConnState, State) ->
	{ok, State}.

websocket_info({send, Package}, _, State) ->
	?LOG1({send, Package}),
	{reply, {binary, Package}, State};	 
websocket_info(_Msg, _ConnState, State) ->
	{ok, State}.

websocket_terminate(Reason, _ConnState, State) ->
	ok.

