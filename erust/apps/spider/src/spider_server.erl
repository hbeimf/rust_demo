% spider_server.erl

% sync_server.erl

%% gen_server代码模板

-module(spider_server).

-behaviour(gen_server).
% --------------------------------------------------------------------
% Include files
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% External exports
% --------------------------------------------------------------------
-export([run/0]).

% gen_server callbacks
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
% -export([stop_rs_server/0]).

-include_lib("glib/include/log.hrl").

% -record(state, { 
% 	code=0
% }).


run() -> 
    gen_server:cast(?MODULE, run),
    ok.

% --------------------------------------------------------------------
% External API
% --------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

% start_link() ->
%     gen_server:start_link(?MODULE, [], []).

% --------------------------------------------------------------------
% Function: init/1
% Description: Initiates the server
% Returns: {ok, State}          |
%          {ok, State, Timeout} |
%          ignore               |
%          {stop, Reason}
% --------------------------------------------------------------------
init([]) ->
	% Port = start_rs_server(),
	% State = #state{code = Code},
	State = [],
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
handle_cast(run, State) ->
	?LOG(run),
	Codes = code_list(),
	fetch_code(Codes),
	{noreply, State};
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


%% priv fun

fetch_code([]) ->
	ok; 
fetch_code([Code|Tail]) -> 
	% ?LOG(Code),
	Url = lists:concat(["http://quotes.money.163.com/service/chddata.html?code=", glib:to_str(Code), "&start=20190101&end=20190121"]),
	% ?LOG(Url),
	Res = glib:http_get(Url),
	% ?LOG(Res),
	case parse_res(Res) of 
		false -> 
			?LOG(Code),
			ok;
		Rows ->
			?LOG(Rows),
			ok
	end, 

	fetch_code(Tail).

parse_res({error, _Reason}) ->
	false;
parse_res(Body) ->
	% ?LOG(Body),
	Body1 = glib:to_str(Body),
	Lines = glib:explode(Body1, "\r\n"),
	% ?LOG(Lines),
	case Lines of 
		[] -> 
			false;
		[_|LineList] -> 
			Rows = lists:map(fun(Line) -> 
				% ?LOG(Line),
				Data = glib:explode(Line, ","),
				% ?LOG(Data),
				[
					{<<"date">>, lists:nth(1, Data)}
					,{<<"price">>, lists:nth(4, Data)}
					,{<<"c_num">>, lists:nth(12, Data)}
				]
			end, LineList),
			Rows
	end.




code_list() -> 
	[
		<<"0900919">>
	].

