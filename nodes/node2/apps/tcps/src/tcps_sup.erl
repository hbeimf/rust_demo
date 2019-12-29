%%%-------------------------------------------------------------------
%% @doc tcps top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(tcps_sup).

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
    Port = sys_config:get_config(tcp, port),
    {ok, _} = ranch:start_listener(tcp_server, 100, ranch_tcp, [{port, Port}, {max_connections, 1000000}], tcps_actor, []),
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    {ok, { {one_for_all, 0, 1}, []} }.

%%====================================================================
%% Internal functions
%%====================================================================
