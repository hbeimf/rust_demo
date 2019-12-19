%% gen_server代码模板

-module(sys_config).

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

% --------------------------------------------------------------------
% External API
% --------------------------------------------------------------------
-export([get_config/1, get_config/2, reload/0, set_config/2, set_aes_key/0, redis_cluster/0, is_debug/0, node_id/0]).
-define(ETS_OPTS,[set, public ,named_table , {keypos,2}, {heir,none}, {write_concurrency,true}, {read_concurrency,true}]).

-define(SYS_CONFIG, sys_config).
-record(sys_config, {
	key,
	val
}).

-include_lib("glib/include/log.hrl").
-define(TIMER, 3000).

is_debug() ->
	case  get_config(debug) of
        {ok, Config} -> 
            {_, {is_debug, IsDebug}, _} = lists:keytake(is_debug, 1, Config),
            case IsDebug of 
            	1 -> 
            		true;
            	_ -> 
            		false
            end;
        _ -> 
            false
    end.

node_id() -> 
	case  get_config(node) of
	        {ok, Config} -> 
	            	get_by_key(id, Config, 0);
	        _ -> 
	            0
	end.

get_by_key(Key, TupleList) ->
	get_by_key(Key, TupleList, <<"">>).

get_by_key(Key, TupleList, Default) ->
	case lists:keytake(Key, 1, TupleList) of 
		{_, {_, undefined}, _} ->
			Default;
		{_, {_, Val}, _} ->
			Val;
		_ ->
			Default
	end.


% sys_config:reload().
reload() ->
	case read_config_file() of
		{ok, ConfigList} -> 
			% Aes = {aes,[{key,go:aes_key()}]},
			% ConfigList1 = [Aes|ConfigList],

			lists:foreach(fun({Key, Val}) -> 
				ets:insert(?SYS_CONFIG, #sys_config{key=Key, val=Val})
			end, ConfigList),
			ok;
		_ -> 
			ok
	end,
	ok.

redis_cluster() ->
	{ok, ConfigList} = get_config(redis_cluster),
	% ?LOG(ConfigList),
	lists:map(fun({_Key, Config}) -> 
		[Ip, Port|_] = glib:explode(Config, ":"),
		{Ip, glib:to_integer(Port)}
	end, ConfigList).

% sys_config:set_aes_key().
set_aes_key() ->
	% {ok, Key} = go:aes_key(),
	Key = <<"123456">>,
	set_config(aes, [{key, Key}]).

set_config(Key, Val) ->
	ets:insert(?SYS_CONFIG, #sys_config{key=Key, val=Val}).	

% sys_config:get_config(mysql).
% :sys_config.get_config(:mysql)
get_config(Key) -> 
	case ets:match_object(?SYS_CONFIG, #sys_config{key = Key,_='_'}) of
		[{?SYS_CONFIG, Key, Val}] -> {ok, Val};
		[] ->{error,not_exist}
	end.

% sys_config:get_config(account_api, login).
get_config(Sec, Key) ->
	case get_config(Sec) of
		{ok,Val} ->
			glib:get_by_key(Key, Val, <<"">>);
		_ ->
			false
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
	% glib:write_req(start_sys_config, "debug", true),

	?MODULE = ets:new(?SYS_CONFIG, ?ETS_OPTS),

 %    case read_config_file() of
	% 	{ok, ConfigList} -> 
	% 		% ?LOG(ConfigList),
	% 		% {aes,[{key,"123456"}]},
	% 		Aes = {aes,[{key,go:aes_key()}]},
	% 		ConfigList1 = [Aes|ConfigList],

	% 		lists:foreach(fun({Key, Val}) -> 
	% 			ets:insert(?SYS_CONFIG, #sys_config{key=Key, val=Val})
	% 		end, ConfigList1),
	% 		ok;
	% 	_ -> 
	% 		ok
	% end,
	reload(),
	% set_aes_key(),
	erlang:send_after(?TIMER, self(), update_db),
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
handle_info(update_db, State) ->
    set_aes_key(),
    {noreply, []};
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
	% glib:write_req(stop_sys_config, "debug", true),
    ok.

% --------------------------------------------------------------------
% Func: code_change/3
% Purpose: Convert process state when code is changed
% Returns: {ok, NewState}
% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.


% private functions

read_config_file() -> 
	ConfigFile = root_dir() ++ "config.ini",
	case file_get_contents(ConfigFile) of
		{ok, Config} -> 
			zucchini:parse_string(Config);
		_ -> 
			ok
	end.

root_dir() ->
	replace(os:cmd("pwd"), "\n", "/"). 

file_get_contents(Dir) ->
	case file:read_file(Dir) of
		{ok, Bin} ->
			% {ok, binary_to_list(Bin)};
			{ok, Bin};
		{error, Msg} ->
			{error, Msg}
	end.

replace(Str, SubStr, NewStr) ->
	case string:str(Str, SubStr) of
		Pos when Pos == 0 ->
			Str;
		Pos when Pos == 1 ->
			Tail = string:substr(Str, string:len(SubStr) + 1),
			string:concat(NewStr, replace(Tail, SubStr, NewStr));
		Pos ->
			Head = string:substr(Str, 1, Pos - 1),
			Tail = string:substr(Str, Pos + string:len(SubStr)),
			string:concat(string:concat(Head, NewStr), replace(Tail, SubStr, NewStr))
	end.
