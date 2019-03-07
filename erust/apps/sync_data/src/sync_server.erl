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
handle_info({update_date, Data}, State) -> 
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
	% stop_rs_server(),
	ok.

% --------------------------------------------------------------------
% Func: code_change/3
% Purpose: Convert process state when code is changed
% Returns: {ok, NewState}
% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

