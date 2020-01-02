%%%-------------------------------------------------------------------
%% @doc wsc_common top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(wsc_common_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).
-export([start_wsc_pool/1]).


%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================
start_wsc_pool(PoolId) ->
    Params = {PoolId},
    supervisor:start_child(?SERVER, [Params]).


start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    RestartStrategy = simple_one_for_one,
    MaxRestarts = 0,
    MaxSecondsBetweenRestarts = 1,

    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

    ChildSup = child_sup(wsc_common_sup_sup),

    {ok, {SupFlags, [ChildSup]}}.

%%====================================================================
%% Internal functions
%%====================================================================
%%
%% child(Mod) ->
%% 	Child = {Mod, {Mod, start_link, []},
%%                permanent, 5000, worker, [Mod]},
%%                Child.


child_sup(Mod) ->
    Child = {Mod, {Mod, start_link, []},
        permanent, 5000, supervisor, [Mod]},
    Child.