% sys_log_worker.erl

%% gen_server代码模板

-module(sys_log_worker).

-behaviour(gen_server).
% --------------------------------------------------------------------
% Include files
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% External exports
% --------------------------------------------------------------------
-export([log/2]).

% gen_server callbacks
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
% -export([stop_rs_server/0]).

-include_lib("glib/include/log.hrl").

-record(state, { 
	port=0
}).


log(Pid, Log) ->
	% ?LOG({Pid, Log}),
	gen_server:cast(Pid, {write, Log}),
	ok.

% --------------------------------------------------------------------
% External API
% --------------------------------------------------------------------
% start_link() ->
% 	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
start_link(LogFile) ->
	gen_server:start_link(?MODULE, [LogFile], []).


% --------------------------------------------------------------------
% Function: init/1
% Description: Initiates the server
% Returns: {ok, State}          |
%          {ok, State, Timeout} |
%          ignore               |
%          {stop, Reason}
% --------------------------------------------------------------------
init([LogFile]) ->
	sys_log_ets:set_config(LogFile, self()),
	% Port = start_rs_server(),
	% State = #state{port = Port},
	State = [LogFile],
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
handle_call(Request, _From, State) ->
	?LOG(Request),
	Reply = ok,
	{reply, Reply, State}.

% --------------------------------------------------------------------
% Function: handle_cast/2
% Description: Handling cast messages
% Returns: {noreply, State}          |
%          {noreply, State, Timeout} |
%          {stop, Reason, State}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_cast({write, Log}, [LogFile|_] = State) ->
	% ?LOG({LogFile, Log}),
	sys_log:log_json(Log, LogFile),
	{noreply, State};
handle_cast(Msg, State) ->
	?LOG(Msg),
	{noreply, State}.

% --------------------------------------------------------------------
% Function: handle_info/2
% Description: Handling all non call/cast messages
% Returns: {noreply, State}          |
%          {noreply, State, Timeout} |
%          {stop, Reason, State}            (terminate/2 is called)
% --------------------------------------------------------------------
% handle_info({#Port<0.51859>,{exit_status,143}}, State) ->
% handle_info({Port, {exit_status, _}}, State=#state{port=Port}) ->
% 	?LOG(Port),
% 	NewPort = start_rs_server(),
% 	{noreply, State#state{port = NewPort}};
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

