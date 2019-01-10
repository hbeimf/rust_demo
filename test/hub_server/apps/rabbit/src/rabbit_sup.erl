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
	% rabbit:receive_demo(),
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
     % RabbitPub = {rabbit_pub_work, {rabbit_pub_work, start_link, []},
     %           permanent, 5000, worker, [rabbit_pub_work]},

     %   RabbitSub = {rabbit_sub_work, {rabbit_sub_work, start_link, []},
     %           permanent, 5000, worker, [rabbit_sub_work]},

       Send = {demo_send, {demo_send, start_link, []},
               permanent, 5000, worker, [demo_send]},

          % Receive = {demo_receive, {demo_receive, start_link, []},
          %      permanent, 5000, worker, [demo_receive]},
               
    Children = [Send],

    {ok, { {one_for_all, 10, 10}, Children} }.


%%====================================================================
%% Internal functions
%%====================================================================
