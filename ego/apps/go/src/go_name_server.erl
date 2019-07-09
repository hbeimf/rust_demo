%% gen_server代码模板

-module(go_name_server).

-behaviour(gen_server).
% --------------------------------------------------------------------
% Include files
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% External exports
% --------------------------------------------------------------------
-export([]).

% gen_server callbacks
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

% -record(state, {}).

% --------------------------------------------------------------------
% External API
% --------------------------------------------------------------------
-export([get_gombox/0]).


-export([start_goroutine/0, stop_goroutine/1, stop_by_name/1, send_cast/2]).

start_goroutine() ->
    gen_server:call(?MODULE, start_goroutine).


stop_by_name(ServerName) ->
    {ok, {_, Host} } = application:get_env(go, go_mailbox),
    stop_goroutine({ServerName, Host}).

stop_goroutine(GoMBox) ->
    gen_server:call(?MODULE, {stop_goroutine, GoMBox}).

send_cast(GoMBox, Msg) ->
    gen_server:cast(?MODULE, {send_cast, GoMBox, Msg}).

get_gombox() ->
    gen_server:call(?MODULE, get_gombox).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


% --------------------------------------------------------------------
% Function: init/1
% Description: Initiates the server
% Returns: {ok, State}          |
%          {ok, State, Timeout} |
%          ignore               |
%          {stop, Reason}
% --------------------------------------------------------------------
init([]) ->
    ListGoServer = lists:foldl(fun(_I, Res)->
        GoMBox = start_gombox(),
        [GoMBox|Res]
    end, [], lists:seq(1, 500)),
    {ok, ListGoServer}.

% --------------------------------------------------------------------
% Function: handle_call/3
% Description: Handling call messages
% Returns: {reply, Reply, State}          |
%          {reply, Reply, State, Timeout} |
%          {noreply, State}               |
%          {noreply, State, Timeout}      |
%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%          {stop, Reason, State}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_call(get_gombox, _From, State) ->
    [GoMBox|T] = State,
    NewState = lists:append(T, [GoMBox]),
    {reply, GoMBox, NewState};

%% 启动一个新的　go 进程，　并返回　进程号 {Pid}　
handle_call(start_goroutine, _From, State) ->
    GoMBox = start_gombox(),
    % NewState = gombox_list(),
    NewState = [GoMBox|State],
    {reply, GoMBox, NewState};
handle_call({stop_goroutine, GoMBox}, _From, State) ->
    {ok, {GoSrv, _Host} } = application:get_env(go, go_mailbox),
    {ServerName, _} = GoMBox,
    NewState = case ServerName of
        GoSrv ->
            State;
        _ ->
            gen_server:cast(GoMBox, stop),
            lists:delete(GoMBox, State)
    end,
    {reply, GoMBox, NewState};
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

% --------------------------------------------------------------------
% Function: handle_cast/2
% Description: Handling cast messages
% Returns: {noreply, State}          |
%          {noreply, State, Timeout} |
%          {stop, Reason, State}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_cast({send_cast, GoMBox, Msg}, State) ->
    io:format("send cast !! ============== ~n~n"),
    gen_server:cast(GoMBox, {Msg, self()}),
    {noreply, State};
handle_cast(_Msg, State) ->
    {noreply, State}.

% --------------------------------------------------------------------
% Function: handle_info/2
% Description: Handling all non call/cast messages
% Returns: {noreply, State}          |
%          {noreply, State, Timeout} |
%          {stop, Reason, State}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_info(Info, State) ->
    % 接收来自go 发过来的异步消息
    io:format("~nhandle info BBB!!============== ~n~p~n", [Info]),
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
% Purpose: Convert process state when code is changed
% Returns: {ok, NewState}
% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


% private functions

start_gombox() ->
    {ok, {GoSrv, Host} } = application:get_env(go, go_mailbox),
    {_, ServerName} = gen_server:call({GoSrv, Host}, start_goroutine),
    {ServerName, Host}.

