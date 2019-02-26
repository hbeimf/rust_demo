%% gen_server代码模板

-module(rs_server_monitor).

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

-include_lib("glib/include/log.hrl").

-record(state, { 
	port=0
}).

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
	Port = start_rs_server(),
	State = #state{port = Port},
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
handle_info({Port, {exit_status, _}}, State=#state{port=Port}) ->
	?LOG(Port),
	NewPort = start_rs_server(),
	{noreply, State#state{port = NewPort}};
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

start_rs_server() ->
	CmdPath = code:lib_dir(rs, priv),
	% ?LOG(CmdPath),
	RootDir = glib:root_dir(),
	% ?LOG(RootDir),
	Cmd = lists:concat([CmdPath, "/rs-server ", "--config ", CmdPath, "/config.ini -d ", RootDir, "logs -l debug -p ", CmdPath, "/rs.pid"]),
	% RsServer = lists:concat([CmdPath, "/rs-server ", "--config ", CmdPath, "/config.ini -d ", RootDir, "logs -l debug"]),
	?LOG(Cmd),
	% os:cmd(RsServer),
	Port = open_port({spawn, Cmd},[exit_status]),
	?LOG(Port),
	Port.
