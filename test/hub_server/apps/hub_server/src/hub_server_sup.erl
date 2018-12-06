%%%-------------------------------------------------------------------
%% @doc hub_server top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(hub_server_sup).

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
    {ok, { {one_for_all, 0, 1}, []} }.
    % Server = {client, {client, start_link, []},
    %            permanent, 5000, worker, [client]},

    % Children = [Server],
    % {ok, { {one_for_all, 10, 10}, Children} }.

    

%%====================================================================
%% Internal functions
%%====================================================================
