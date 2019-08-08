%%%-------------------------------------------------------------------
%% @doc mysqlc top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(mysqlc_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_child/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

% mysqlc_sup:start_child().
start_child() -> 
	MysqlcConnSup =  {mysqlc_conn_sup, {mysqlc_conn_sup, start_link, []},
               temporary, 5000, supervisor, [mysqlc_conn_sup]},
	   
	supervisor:start_child(?SERVER, MysqlcConnSup).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
% init([]) ->
%     {ok, { {one_for_all, 0, 1}, []} }.

init([]) ->
    % PoolOptions  = [{size, 10}, {max_overflow, 20}],
    % Pools  = rconf:read_config(mysql),

    % ChildSpecs = lists:foldl(fun({Pool, MySqlOptions}, Reply) -> 
    % 		[mysql_poolboy:child_spec(Pool, PoolOptions, MySqlOptions)|Reply]
    % end, [], Pools),

    % {ok, {{one_for_one, 10, 10}, ChildSpecs}}. 



	Monitor = {mysqlc_monitor, {mysqlc_monitor, start_link, []},
               permanent, 5000, worker, [mysqlc_monitor]},
              
    	Children = [Monitor],

    {ok, { {one_for_all, 10, 10}, Children} }.



%%====================================================================
%% Internal functions
%%====================================================================
