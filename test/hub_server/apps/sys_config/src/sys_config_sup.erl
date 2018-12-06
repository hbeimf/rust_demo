%%%-------------------------------------------------------------------
%% @doc sys_config top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(sys_config_sup).

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

    SysConfig = {sys_config, {sys_config, start_link, []},
               permanent, 5000, worker, [sys_config]},


    Children = [SysConfig],

    {ok, { {one_for_all, 10, 10}, Children} }.

%%====================================================================
%% Internal functions
%%====================================================================
