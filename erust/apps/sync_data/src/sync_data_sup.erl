%%%-------------------------------------------------------------------
%% @doc sync_data top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(sync_data_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_child/2]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_child(Code, Data) ->
    supervisor:start_child(?SERVER, [Code, Data]).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
% init([]) ->
%     {ok, { {one_for_all, 0, 1}, []} }.
init([]) ->
    Element = {sync_server, {sync_server, start_link, []},
               temporary, brutal_kill, worker, [sync_server]},
    Children = [Element],
    RestartStrategy = {simple_one_for_one, 0, 1},
    {ok, {RestartStrategy, Children}}.


%%====================================================================
%% Internal functions
%%====================================================================
