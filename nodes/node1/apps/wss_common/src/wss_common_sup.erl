%%%-------------------------------------------------------------------
%% @doc wss_common top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(wss_common_sup).

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
        child_sup(wss_common_pool_sup)
%%        , child(wsc_common_pool_actor)
    ].

%%child(Mod) ->
%%    Child = {Mod, {Mod, start_link, []},
%%        permanent, 5000, worker, [Mod]},
%%    Child.

child_sup(Mod) ->
    Child = {Mod, {Mod, start_link, []},
        permanent, 5000, supervisor, [Mod]},
    Child.
