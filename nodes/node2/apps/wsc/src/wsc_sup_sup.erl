%%%-------------------------------------------------------------------
%% @doc wsc top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(wsc_sup_sup).

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
  {Ip, Port} = {"127.0.0.1", 8000},
  PoolSpecs = {wsc:pool_name(),{poolboy,start_link,
    [[{name,{local,wsc:pool_name()}},
      {worker_module,wsc_call_actor},
      {size,100},
      {max_overflow,20}],
      [Ip, glib:to_integer(Port)]]},
    permanent,5000,worker,
    [poolboy]},

  Children = [PoolSpecs],

  {ok, {{one_for_one, 10, 10}, Children}}.

%%====================================================================
%% Internal functions
%%====================================================================
