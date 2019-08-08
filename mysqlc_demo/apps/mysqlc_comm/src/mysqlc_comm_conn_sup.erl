% mysqlc_comm_conn_sup.erl
%%%-------------------------------------------------------------------
%% @doc mysqlc top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(mysqlc_comm_conn_sup).

-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

-include_lib("glib/include/log.hrl").
%%====================================================================
%% API functions
%%====================================================================

% start_link(ChannelId) ->
%     supervisor:start_link({local, ?SERVER}, ?MODULE, [ChannelId]).

start_link(PoolConfig) ->
    supervisor:start_link(?MODULE, [PoolConfig]).

% start_link(ChannelId) ->
%     supervisor:start_link({local, ?SERVER}, ?MODULE, [ChannelId]).


%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
% init([]) ->
%     {ok, { {one_for_all, 0, 1}, []} }.

init([PoolConfig|_]) ->
	Size = maps:get(pool_size, PoolConfig, 10),
	
    PoolOptions  = [{size, Size}, {max_overflow, 20}],
    Pools = get_pools(PoolConfig),

    ChildSpecs = lists:foldl(fun({Pool, MySqlOptions}, Reply) -> 
    		[mysql_poolboy:child_spec(Pool, PoolOptions, MySqlOptions)|Reply]
    end, [], Pools),

    ?LOG(ChildSpecs),
    {ok, {{one_for_one, 10, 10}, ChildSpecs}}.

%%====================================================================
%% Internal functions
%%====================================================================
get_pools(#{pool_id := PoolId,
	host := Host, 
            port := Port, 
            user := User, 
            password := Password, 
            database := Database
	} = PoolConfig) ->

	PoolName = mysqlc_comm_pool_name:pool_name(PoolId),

	[{PoolName,[{host, Host},
	     {port, to_integer(Port)},
	     {user,User},
	     {password, Password},
	     {database,Database},
	     {prepare,[{set_code,"set names utf8"}]}]}
	     ].

to_integer(X) when is_list(X) -> list_to_integer(X);
to_integer(X) when is_binary(X) -> binary_to_integer(X);
to_integer(X) when is_integer(X) -> X;
to_integer(X) -> X.	
