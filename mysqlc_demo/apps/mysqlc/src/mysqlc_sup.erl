%%%-------------------------------------------------------------------
%% @doc mysqlc top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(mysqlc_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_child/0]).
-export([start_new_pool/1]).
-export([start_new_pool_test/0, test/0]).
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
	MysqlcConnSup =  {mysqlc_conn_sup, {mysqlc_conn_sup, start_link, [0]},
               temporary, 5000, supervisor, [mysqlc_conn_sup]},
	   
	supervisor:start_child(?SERVER, MysqlcConnSup).

% mysqlc_sup:start_new_pool_test().
start_new_pool_test() ->
    ChannelIds = lists:seq(1, 5),
    lists:foreach(fun(ChannelId) -> 
        start_new_pool(ChannelId)
    end, ChannelIds).


% test() -> 
%     ok.

% host = "127.0.0.1"
% port = 3306 
% user = "root"
% password = "123456"
% database = "xdb"

test() ->
    PoolConfigList = [
        #{
            channel_id=>1,
            host=> "127.0.0.1", 
            port=>3306, 
            user=>"root", 
            password=>"123456", 
            database=>"xdb",
            pool_size => 2
        }
        , #{
            channel_id=>2,
            host=> "127.0.0.1", 
            port=>3306, 
            user=>"root", 
            password=>"123456", 
            database=>"xdb",
            pool_size=> 5
        }
        , #{
            channel_id=>3,
            host=> "127.0.0.1", 
            port=>3306, 
            user=>"root", 
            password=>"123456", 
            database=>"xdb"
            % pool_size=> 5
        }

    ],
    lists:foreach(fun(PoolConfig) -> 
        start_new_pool(PoolConfig)
    end, PoolConfigList).

% mysqlc_sup:start_new_pool(1).
start_new_pool(#{channel_id := ChannelId} = PoolConfig) ->
    SupId = lists:concat(["mysqlc_conn_sup_", ChannelId]),
    MysqlcConnSup =  {SupId, {mysqlc_conn_sup, start_link, [PoolConfig]},
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



	% Monitor = {mysqlc_monitor, {mysqlc_monitor, start_link, []},
 %               permanent, 5000, worker, [mysqlc_monitor]},
              
 %    	Children = [Monitor],

        Children = [],

    {ok, { {one_for_all, 10, 10}, Children} }.



%%====================================================================
%% Internal functions
%%====================================================================
