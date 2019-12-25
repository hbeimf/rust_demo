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
-export([stop_rs_server/0]).

-include("log.hrl").

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
	stop_rs_server(),
	ok.

% --------------------------------------------------------------------
% Func: code_change/3
% Purpose: Convert process state when code is changed
% Returns: {ok, NewState}
% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

% rs_server_monitor:stop_rs_server().
stop_rs_server() ->
 	CmdPath = code:lib_dir(rs, priv),
	PidFile = lists:concat([CmdPath, "/rs.pid"]),
	Cmd             = lists:flatten(["kill -9 $(cat ", PidFile, ")"]),
    	os:cmd(Cmd),
	ok.

start_rs_server() ->
	CmdPath = code:lib_dir(rs, priv),
	RootDir = root_dir(),
	Cmd = lists:concat([CmdPath, "/rs-server ", "--config ", CmdPath, "/config.ini -d ", RootDir, "logs -l debug -p ", CmdPath, "/rs.pid"]),
	?LOG(Cmd),
	Port = open_port({spawn, Cmd},[exit_status]),
	Port.


root_dir() ->
	replace(os:cmd("pwd"), "\n", "/"). 

replace() -> 
	S = replace("xxx'yyy'zzz", "'", "\\'"),
	io:format("str: ~p ~n ", [S]).

replace(Str, SubStr, NewStr) ->
	replace("", Str, SubStr, NewStr). 

replace(Result, Str, SubStr, NewStr) ->
	case string:str(Str, SubStr) of
		Pos when Pos == 0 ->
			string:concat(Result, Str);
		Pos when Pos == 1 ->
			Tail = string:substr(Str, string:len(SubStr) + 1),
			replace(string:concat(Result, NewStr), Tail, SubStr, NewStr);
		Pos ->
			Head = string:substr(Str, 1, Pos - 1),
			Tail = string:substr(Str, Pos + string:len(SubStr)),
			replace(string:concat(Result, string:concat(Head, NewStr)), Tail, SubStr, NewStr)
	end.