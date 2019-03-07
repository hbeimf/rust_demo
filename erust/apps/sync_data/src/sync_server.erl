% sync_server.erl

%% gen_server代码模板

-module(sync_server).

-behaviour(gen_server).
% --------------------------------------------------------------------
% Include files
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% External exports
% --------------------------------------------------------------------
-export([start_code/2]).

% gen_server callbacks
-export([start_link/2]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
% -export([stop_rs_server/0]).

% -include("log.hrl").

-record(state, { 
	code=0
	,data = []
}).

-include_lib("glib/include/log.hrl").
-define(TIMER, 300).

%% 启动一条数据
start_code(Code, Data) -> 
	case table_code_list:select(Code) of 
		[] -> 
			case sync_data_sup:start_child(Code, Data) of 
				{ok, Pid} -> 
					table_code_list:add(Code, Pid),
					true;
				_ -> 
					false
			end;
		[C|_] -> 
			Pid = table_code_list:get_client(C, pid),
			Pid ! {update_date, Data},
			ok
	end.

% --------------------------------------------------------------------
% External API
% --------------------------------------------------------------------
% start_link() ->
% 	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
start_link(Code, Data) ->
    gen_server:start_link(?MODULE, [Code, Data], []).

% --------------------------------------------------------------------
% Function: init/1
% Description: Initiates the server
% Returns: {ok, State}          |
%          {ok, State, Timeout} |
%          ignore               |
%          {stop, Reason}
% --------------------------------------------------------------------
init([Code, Data]) ->
	erlang:send_after(?TIMER, self(), run),
	% Port = start_rs_server(),
	State = #state{code = Code, data=Data},
	% State = [],
	{ok, State}.

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
	% ?LOG(Request),
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
	% ?LOG(Msg),
	{noreply, State}.

% --------------------------------------------------------------------
% Function: handle_info/2
% Description: Handling all non call/cast messages
% Returns: {noreply, State}          |
%          {noreply, State, Timeout} |
%          {stop, Reason, State}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_info(run, State = #state{code=Code, data= Data}) ->
	% ?LOG({run, Data}), 
	run(Data, Code),
	{noreply, State};
handle_info({update_date, Data}, State) -> 
	erlang:send_after(?TIMER, self(), run),
	{noreply, State#state{data = Data}};	
handle_info(_Info, State) ->
	% ?LOG(Info),
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

% priv fun =================

run([], _Code) ->
	ok; 
run(Data, Code) ->
	% ?LOG(Data),
	Data1 = lists:keysort(1, Data),
	% ?LOG(Data1),
	Data2 = lists:reverse(Data1),
	% ?LOG(Data2),
	{List1, List2} = lists:split(5, Data2),
	% ?LOG({List1, List2}),
	case find_exception(List1) of
		{true, Per} -> 
			?LOG({Code, true, Per}),
			table_maybe_codes_list:add(Code, Per),
			ok;
		_ -> 
			ok
	end,
	ok. 

find_exception(Data) ->
	[{_, _,First}, _, _, _, {_, _, Last}|_] = lists:keysort(3, Data),
	
	First1 = glib:to_integer(First),
	Last1 = glib:to_integer(Last),

	Per = ( Last1 - First1 ) / First1,
	% ?LOG({First, Last, Per}),
	case Per >= 0.5 of 
		true -> 
			{true, glib:three(Per)};
		_ -> 
			false
	end. 


