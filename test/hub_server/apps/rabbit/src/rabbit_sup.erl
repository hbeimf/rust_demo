%%%-------------------------------------------------------------------
%% @doc rabbit top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(rabbit_sup).

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
	rabbit:receive_demo(),
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    % {ok, { {one_for_all, 0, 1}, []} }.
     RabbitSend = {rabbit_pub_work, {rabbit_pub_work, start_link, []},
               permanent, 5000, worker, [rabbit_pub_work]},
               
    Children = [RabbitSend],

    {ok, { {one_for_all, 10, 10}, Children} }.


%%====================================================================
%% Internal functions
%%====================================================================
