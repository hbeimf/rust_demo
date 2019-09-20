%%%-------------------------------------------------------------------
%% @doc mysqlc_channel top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(mysqlc_channel_sup).

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
% init([]) ->
%     {ok, { {one_for_all, 0, 1}, []} }.
init([]) ->
    Mysqlc_channel_monitor = {mysqlc_channel_monitor, {mysqlc_channel_monitor, start_link, []},
               permanent, 5000, worker, [mysqlc_channel_monitor]},
              
      Children = [Mysqlc_channel_monitor],
    {ok, { {one_for_one, 10, 10}, Children} }.


%%====================================================================
%% Internal functions
%%====================================================================
