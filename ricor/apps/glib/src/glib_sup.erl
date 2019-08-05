%%%-------------------------------------------------------------------
%% @doc glib top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(glib_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_log/1]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

% log pid ets table
-define(ETS_OPTS,[set, public ,named_table , {keypos,2}, {heir,none}, {write_concurrency,true}, {read_concurrency,false}]).

-define(LOG_DB, log_db).
-record(log_db, {
	key,
	pid
}).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
	init_log_db(),
	supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_log(Root) -> 
	Key = glib:to_binary(Root),
	case select(Key) of
		{ok, Pid} -> 
			case erlang:is_pid(Pid) andalso glib:is_pid_alive(Pid) of 
				true -> 
					Pid;
				_ -> 
					{ok, Pid1} = start_child(log, Root),
					insert(Key, Pid1),
					Pid1
			end;
		_ -> 
			{ok, Pid} = start_child(log, Root),
			insert(Key, Pid),
			Pid
	end.

start_child(Mod, Root) ->   
	Child = child(Mod, glib:to_str(Root)),
	supervisor:start_child(?SERVER, Child).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    Children = [
    	child(sys_config)
    	, child(code_lock)
    ],

    {ok, { {one_for_one, 10, 10}, Children} }.

%%====================================================================
%% Internal functions
%%====================================================================
child(Mod) ->
	Child = {Mod, {Mod, start_link, []},
               permanent, 5000, worker, [Mod]},
               Child.

child(Mod, Root) ->
	Child = {Mod, {Mod, start_link, [Root]},
               permanent, 5000, worker, [Mod]},
               Child.


child_sup(Mod) ->
              Child = {Mod, {Mod, start_link, []},
               permanent, 5000, supervisor, [Mod]},
               Child. 


init_log_db() ->
	ets:new(?LOG_DB, ?ETS_OPTS).

insert(Key, Pid) ->
	ets:insert(?LOG_DB, #log_db{key=Key, pid=Pid}).

select(Key) -> 
	case ets:match_object(?LOG_DB, #log_db{key = Key,_='_'}) of
		[{?LOG_DB, Key, Pid}] -> {ok, Pid};
		[] ->{error,not_exist}
	end.

delete(Key) ->
	ets:delete(?LOG_DB, Key).
