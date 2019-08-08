%%%-------------------------------------------------------------------
%% @doc mysqlc_comm top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(mysqlc_comm_sup).
-include_lib("glib/include/log.hrl").
-behaviour(supervisor).

%% API
-export([start_link/0]).
-export([start_new_pool/1]).
-export([ test/0]).
-export([children/0]).
%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

children() -> 
    Children = supervisor:which_children(?SERVER),
    Children.

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
    %% 也许这个连接池已经存在，先尝试关掉，
    Result = supervisor:terminate_child(?SERVER, SupId),
    ?LOG({Result}),

    MysqlcConnSup =  {SupId, {mysqlc_comm_conn_sup, start_link, [PoolConfig]},
               temporary, 5000, supervisor, [mysqlc_comm_conn_sup]},
    supervisor:start_child(?SERVER, MysqlcConnSup).




%%====================================================================
%% Supervisor callbacks
%%====================================================================

init([]) ->
    Mysqlc_pool_name = {mysqlc_comm_pool_name, {mysqlc_comm_pool_name, start_link, []},
               permanent, 5000, worker, [mysqlc_comm_pool_name]},
              
      Children = [Mysqlc_pool_name],
    {ok, { {one_for_all, 10, 10}, Children} }.



%%====================================================================
%% Internal functions
%%====================================================================
