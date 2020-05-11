% sys_log_ets.erl
% mysqlc_comm_pool_name.erl
% pool_name.erl
-module(sys_log_ets).
-behaviour(gen_server).
% -compile(export_all).
% --------------------------------------------------------------------
% External exports
% --------------------------------------------------------------------
% -export([pool_name/1]).

% gen_server callbacks
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

% --------------------------------------------------------------------
% External API
% --------------------------------------------------------------------
-export([get_config/1, set_config/2]).
-define(ETS_OPTS,[set, public ,named_table , {keypos,2}, {heir,none}, {write_concurrency,true}, {read_concurrency,true}]).

-define(SYS_CONFIG, sys_log_ets).
-record(sys_log_ets, {
	key,
	val
}).

% % mysqlc_pool_name:pool_name(ChannelId).
% pool_name(ChannelId) ->
% 	case get_config(ChannelId) of 
% 		{ok, Val} -> 
% 			Val;
% 		_ ->  
% 			PoolName = lists:concat(["pool_", ChannelId]),
% 			Pn = to_atom(PoolName),
% 			set_config(ChannelId, Pn),
% 			Pn
% 	end.

% to_atom(A) when is_atom(A) ->
%     A;
% to_atom(B) when is_binary(B) ->
%     list_to_atom(binary_to_list(B));
% to_atom(L) when is_list(L) ->
%     list_to_atom(L).



set_config(Key, Val) ->
	ets:insert(?SYS_CONFIG, #?SYS_CONFIG{key=Key, val=Val}),
	ok. 

% sys_config:get_config(mysql).
% :sys_config.get_config(:mysql)
get_config(Key) -> 
	case ets:match_object(?SYS_CONFIG, #?SYS_CONFIG{key = Key,_='_'}) of
		[{?SYS_CONFIG, Key, Val}] -> {ok, Val};
		[] ->{error,not_exist}
	end.

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
	ets:new(?SYS_CONFIG, ?ETS_OPTS),
    	{ok, []}.

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
handle_cast(_Msg, State) ->
    {noreply, State}.

% --------------------------------------------------------------------
% Function: handle_info/2
% Description: Handling all non call/cast messages
% Returns: {noreply, State}           %          {noreply, State, Timeout} |
%          {stop, Reason, State}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

% handle_info(Info, State) ->
%     % 接收来自go 发过来的异步消息
%     io:format("~nhandle info BBB!!============== ~n~p~n", [Info]),
%     {noreply, State}.

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

