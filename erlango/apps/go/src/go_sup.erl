%%%-------------------------------------------------------------------
%% @doc go top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(go_sup).

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
    % {ok, { {one_for_all, 0, 1}, []} }.
    GoMonitor = {go_monitor_actor, {go_monitor_actor, start_link, []},
      permanent, 5000, worker, [go_monitor_actor]},


    {Ip, Port} = {"127.0.0.1", 8000},
    PoolSpecs = {go_pool,{poolboy,start_link,
             [[{name,{local,go_pool}},
               {worker_module,go_actor},
               {size,100},
               {max_overflow,20}],
      		[Ip, glib:to_integer(Port)]]},
      permanent,5000,worker,
      [poolboy]},

      Children = [GoMonitor, PoolSpecs],

      {ok, {{one_for_one, 10, 10}, Children}}.

%%====================================================================
%% Internal functions
%%====================================================================
