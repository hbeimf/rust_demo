% mysqlc_channel_monitor.erl
%% gen_server代码模板
%% 监控mysql连接是否需 要重启

-module(mysqlc_channel_monitor).

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

-define(SECOND, 1000).


-include_lib("glib/include/log.hrl").
% -record(state, {}).

% --------------------------------------------------------------------
% External API
% --------------------------------------------------------------------
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
	_TRef = erlang:send_after(?SECOND, self(), check_once),
	PoolConfigList = mysqlc_channel_pool:config_list(),
    	{ok, PoolConfigList}.

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
% handle_call({insert, TupleData}, _From, State) ->
%     Reply = ok,
%     NewState = [TupleData|State],
%     {reply, Reply,  NewState};
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
handle_info(check_once, State) ->
	_TRef = erlang:send_after(?SECOND, self(), check_once),

	% ?LOG({check_once, State}),
	check_once(State),

	{noreply, State};
handle_info(_Info, State) ->
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


% % private functions
check_once([]) -> 
	ok;
check_once([PoolConfig|PoolConfigList]) ->
	% ?LOG(PoolConfig),
	#{pool_id := PoolId} = PoolConfig,
	SupId = mysqlc_comm_sup:sup_id(PoolId),

	Sups = mysqlc_comm_sup:children(),
	Sups1 = lists:foldl(fun({Id, Pid, _, _}, Reply) -> 
		[{Id, Pid}|Reply]
	end, [], Sups),

	CurrentSupPid = glib:get_by_key(SupId, Sups1),
	% ?LOG({SupId, Sups, CurrentSupPid}),

	case erlang:is_pid(CurrentSupPid) andalso is_pid_alive(CurrentSupPid) of 
		true -> 
			ok;
		_ -> 
			% ?LOG(error),
			glib:write_req({?MODULE, ?LINE, PoolConfig}, "reconnect-db"),
			mysqlc_comm:start_pool(PoolConfig),
			ok
	end,

	check_once(PoolConfigList).



is_pid_alive(Pid) when node(Pid) =:= node() ->
    is_process_alive(Pid);
is_pid_alive(Pid) ->
    case lists:member(node(Pid), nodes()) of
		false ->
	   	 false;
		true ->
	    	case rpc:call(node(Pid), erlang, is_process_alive, [Pid]) of
				true ->
		    		true;
				false ->
		    		false;
				{badrpc, _Reason} ->
		    		false
	    	end
    end.