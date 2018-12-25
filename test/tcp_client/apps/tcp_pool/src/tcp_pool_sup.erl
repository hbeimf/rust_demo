%%%-------------------------------------------------------------------
%% @doc tcp_pool top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(tcp_pool_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

-include_lib("glib/include/log.hrl").

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
	% {ok, Pools} = application:get_env(tcp_pool, pools),
 %    PoolSpecs = lists:map(fun({Name, SizeArgs, WorkerArgs}) ->
 %        PoolArgs = [{name, {local, Name}},
 %            		{worker_module, example_worker}] ++ SizeArgs,
 %        poolboy:child_spec(Name, PoolArgs, WorkerArgs)
 %    end, Pools),

 %    ?LOG(PoolSpecs),


 % PoolSpecs = [{pool1,{poolboy,start_link,
 %                 [[{name,{local,pool1}},
 %                   {worker_module,example_worker},
 %                   {size,10},
 %                   {max_overflow,20}],
 %                  [{hostname,"127.0.0.1"},
 %                   {database,"db1"},
 %                   {username,"db1"},
 %                   {password,"abc123"}]]},
 %        permanent,5000,worker,
 %        [poolboy]},
 % {pool2,{poolboy,start_link,
 %                 [[{name,{local,pool2}},
 %                   {worker_module,example_worker},
 %                   {size,5},
 %                   {max_overflow,10}],
 %                  [{hostname,"127.0.0.1"},
 %                   {database,"db2"},
 %                   {username,"db2"},
 %                   {password,"abc123"}]]},
 %        permanent,5000,worker,
 %        [poolboy]}]


         PoolSpecs = [{pool1,{poolboy,start_link,
                 [[{name,{local,pool1}},
                   {worker_module,tcp_worker},
                   {size,10},
                   {max_overflow,20}],
        			[]]},
        permanent,5000,worker,
        [poolboy]}],

        {ok, {{one_for_one, 10, 10}, PoolSpecs}}.

    % {ok, { {one_for_all, 0, 1}, []} }.

%%====================================================================
%% Internal functions
%%====================================================================
