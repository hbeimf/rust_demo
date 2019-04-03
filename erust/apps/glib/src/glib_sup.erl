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

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_log(Root) -> 
	start_child(log, Root).

start_child(Mod, Root) ->   
	Child = child(Mod, glib:to_str(Root)),
	supervisor:start_child(?SERVER, Child).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    % {ok, { {one_for_all, 0, 1}, []} }.
        % SysConfig = {sys_config, {sys_config, start_link, []},
        %        permanent, 5000, worker, [sys_config]},

    Children = [
    	child(sys_config)
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