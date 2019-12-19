%%%-------------------------------------------------------------------
%% @doc esnowflake top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(esnowflake_sup).

-behaviour(supervisor).

-include("esnowflake.hrl").

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link(Version) ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, [Version]).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([Version]) ->
    SupFlags = #{
      strategy  => rest_for_one,
      intensity => 1000,
      period    => 3600
     },

    PoolSpec = #{
      id       => 'esnowflake_worker_pool',
      start    => {'esnowflake_worker_pool', start_link, []},
      restart  => permanent,
      shutdown => 2000,
      type     => worker,
      modules  => ['esnowflake_worker_pool']
     },

    WrkSupSpec = #{
      id       => 'esnowflake_worker_sup',
      start    => {'esnowflake_worker_sup', start_link, []},
      restart  => permanent,
      shutdown => 2000,
      type     => supervisor,
      modules  => ['esnowflake_worker_sup']
     },

    StatsSpec = #{
      id       => 'esnowflake_stats',
      start    => {'esnowflake_stats', start_link, [Version, 10]},
      restart  => permanent,
      shutdown => 2000,
      type     => worker,
      modules  => ['esnowflake_stats']
     },

    ?LOG([WrkSupSpec, PoolSpec, StatsSpec]),
    {ok, {SupFlags, [WrkSupSpec, PoolSpec, StatsSpec]}}.
