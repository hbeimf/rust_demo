%%%-------------------------------------------------------------------
%% @doc rs top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(rs_sup).

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
	Child = {rs_server_monitor, {rs_server_monitor, start_link, []},
		permanent, 5000, worker, [rs_server_monitor]},

         PoolSpecs = {rs_client_pool,{poolboy,start_link,
                 [[{name,{local,rs_client_pool}},
                   {worker_module,rs_client},
                   {size,10},
                   {max_overflow,20}],
        			[]]},
        permanent,5000,worker,
        [poolboy]},


        Children = [Child, PoolSpecs],

        {ok, {{one_for_one, 10, 10}, Children}}.

%%====================================================================
%% Internal functions
%%====================================================================
