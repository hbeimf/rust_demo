%%%-------------------------------------------------------------------
%% @doc room top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(wsc_common_sup).

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
        child_sup(wsc_common_pool_sup)
        , child(wsc_common_pool_actor)
    ].

child(Mod) ->
 	Child = {Mod, {Mod, start_link, []},
                permanent, 5000, worker, [Mod]},
                Child.

child_sup(Mod) ->
    Child = {Mod, {Mod, start_link, []},
        permanent, 5000, supervisor, [Mod]},
    Child.


%%Restart = permanent | transient | temporary

%%Restart 这个参数用来告诉supervisor，当该child process挂掉时，是否能够重启它，
%%permanent表示永远可以（不管child process是以何种原因挂掉），
%%temporary表示永远不可以（即挂掉了将不再重启），
%%transient 有点特殊，它表示child process若是因为normal或者shutdown原因结束，
%%则不再重启，否则可以restart（ps:Restart参数设置会覆盖Restart Strategy，
%%譬如一个child process的Restart设置为temporary，supervisor的Restart Strategy
%%是one_for_all，那么当其他某个child process挂掉后，将会导致该child process(temporay)
%%被terminate并且不再被重启）
