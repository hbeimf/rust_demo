-module(go_ws_actor).

-behaviour(websocket_client_handler).

-include_lib("glib/include/log.hrl").

-export([
         start_link/1,
         init/2,
         websocket_handle/3,
         websocket_info/3,
         websocket_terminate/3
        ]).



start_link(Index) ->
    Host = "ws://localhost:8000/ws",
    websocket_client:start_link(Host, ?MODULE, [Index]).

    

init([_Index], _ConnState) ->
    
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
    ?LOG({binary, Bin}),
	{reply, {binary, Bin}, State}.

websocket_terminate(_Reason, _ConnState, _State) ->
    % io:format("~nClient closed in state ~p wih reason ~p~n", [State, Reason]),
    % ?LOG({ws_terminate}),
    ok.
