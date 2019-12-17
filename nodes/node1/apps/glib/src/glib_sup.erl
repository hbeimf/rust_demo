%%%-------------------------------------------------------------------
%% @doc glib top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(glib_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    Children = children(),

    {ok, { {one_for_one, 10, 10}, Children} }.
%%====================================================================
%% Internal functions
%%====================================================================
children() -> 
  [
      
      child(glib_cluster_actor)
  ].


child(Mod) ->
	Child = {Mod, {Mod, start_link, []},
               permanent, 5000, worker, [Mod]},
               Child.

child_sup(Mod) ->
              Child = {Mod, {Mod, start_link, []},
               permanent, 5000, supervisor, [Mod]},
               Child. 