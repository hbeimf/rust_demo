%%%-------------------------------------------------------------------
%% @doc mysqlc top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(mysqlc_conn_sup).

-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

% -export([start_new_pool/1]).
-define(SERVER, ?MODULE).

-include_lib("glib/include/log.hrl").

% % mysqlc_conn_sup:start_new_pool(1).
% start_new_pool(ChannelId) ->
%     % MysqlcConnSup =  {mysqlc_conn_sup, {mysqlc_conn_sup, start_link, [ChannelId]},
%     %            temporary, 5000, supervisor, [mysqlc_conn_sup]},

%     PoolOptions  = [{size, 10}, {max_overflow, 20}],
%     Pools = get_pools(ChannelId),

%     ChildSpecs = lists:foldl(fun({Pool, MySqlOptions}, Reply) -> 
%     		[mysql_poolboy:child_spec(Pool, PoolOptions, MySqlOptions)|Reply]
%     end, [], Pools),   

%      ?LOG(ChildSpecs),
%     supervisor:start_child(?SERVER, ChildSpecs).

%%====================================================================
%% API functions
%%====================================================================

% start_link(ChannelId) ->
%     supervisor:start_link({local, ?SERVER}, ?MODULE, [ChannelId]).

start_link(ChannelId) ->
    supervisor:start_link(?MODULE, [ChannelId]).

% start_link(ChannelId) ->
%     supervisor:start_link({local, ?SERVER}, ?MODULE, [ChannelId]).


%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
% init([]) ->
%     {ok, { {one_for_all, 0, 1}, []} }.

init([ChannelId|_]) ->
    PoolOptions  = [{size, 10}, {max_overflow, 20}],
    Pools = get_pools(ChannelId),

    ChildSpecs = lists:foldl(fun({Pool, MySqlOptions}, Reply) -> 
    		[mysql_poolboy:child_spec(Pool, PoolOptions, MySqlOptions)|Reply]
    end, [], Pools),

    ?LOG(ChildSpecs),
    {ok, {{one_for_one, 10, 10}, ChildSpecs}}.

% init([ChannelId|_]) ->
%     PoolOptions  = [{size, 10}, {max_overflow, 20}],
%     Pools = get_pools(ChannelId),

%     ChildSpecs = lists:foldl(fun({Pool, MySqlOptions}, Reply) -> 
%     		[mysql_poolboy:child_spec(Pool, PoolOptions, MySqlOptions)|Reply]
%     end, [], Pools),

%     {ok, {{one_for_one, 10, 10}, ChildSpecs}}. 


%%====================================================================
%% Internal functions
%%====================================================================
% get_pools(ChannelId) ->
% 	case sys_config:get_config(mysql) of 
% 		{ok, MysqlConfig} -> 
% 			{_, {host, Host}, _} = lists:keytake(host, 1, MysqlConfig),
% 			{_, {port, Port}, _} = lists:keytake(port, 1, MysqlConfig),
% 			{_, {user, User}, _} = lists:keytake(user, 1, MysqlConfig),
% 			{_, {password, Password}, _} = lists:keytake(password, 1, MysqlConfig),
% 			{_, {database, Database}, _} = lists:keytake(database, 1, MysqlConfig),	

% 			% {ok, MysqlLogConfig} = sys_config:get_config(mysql_log),
% 			% {_, {host, Host1}, _} = lists:keytake(host, 1, MysqlLogConfig),
% 			% {_, {port, Port1}, _} = lists:keytake(port, 1, MysqlLogConfig),
% 			% {_, {user, User1}, _} = lists:keytake(user, 1, MysqlLogConfig),
% 			% {_, {password, Password1}, _} = lists:keytake(password, 1, MysqlLogConfig),
% 			% {_, {database, Database1}, _} = lists:keytake(database, 1, MysqlLogConfig),	


% 			[{pool1,[{host, Host},
% 			     {port, to_integer(Port)},
% 			     {user,User},
% 			     {password, Password},
% 			     {database,Database},
% 			     {prepare,[{set_code,"set names utf8"}]}]}
% 			     % ,{pool_log,[{host, Host1},
% 			     % {port, to_integer(Port1)},
% 			     % {user,User1},
% 			     % {password, Password1},
% 			     % {database,Database1},
% 			     % {prepare,[{set_code,"set names utf8"}]}]}
% 			     ]; 
% 		_ -> 
% 			ok
% 	end.

pool_name(1) ->
	pool1;
pool_name(_) ->
	pool.

get_pools(ChannelId) ->
	case sys_config:get_config(mysql) of 
		{ok, MysqlConfig} -> 
			{_, {host, Host}, _} = lists:keytake(host, 1, MysqlConfig),
			{_, {port, Port}, _} = lists:keytake(port, 1, MysqlConfig),
			{_, {user, User}, _} = lists:keytake(user, 1, MysqlConfig),
			{_, {password, Password}, _} = lists:keytake(password, 1, MysqlConfig),
			{_, {database, Database}, _} = lists:keytake(database, 1, MysqlConfig),	

			% {ok, MysqlLogConfig} = sys_config:get_config(mysql_log),
			% {_, {host, Host1}, _} = lists:keytake(host, 1, MysqlLogConfig),
			% {_, {port, Port1}, _} = lists:keytake(port, 1, MysqlLogConfig),
			% {_, {user, User1}, _} = lists:keytake(user, 1, MysqlLogConfig),
			% {_, {password, Password1}, _} = lists:keytake(password, 1, MysqlLogConfig),
			% {_, {database, Database1}, _} = lists:keytake(database, 1, MysqlLogConfig),	


			PoolName = pool_name(ChannelId),

			[{PoolName,[{host, Host},
			     {port, to_integer(Port)},
			     {user,User},
			     {password, Password},
			     {database,Database},
			     {prepare,[{set_code,"set names utf8"}]}]}
			     % ,{pool_log,[{host, Host1},
			     % {port, to_integer(Port1)},
			     % {user,User1},
			     % {password, Password1},
			     % {database,Database1},
			     % {prepare,[{set_code,"set names utf8"}]}]}
			     ]; 
		_ -> 
			ok
	end.

to_integer(X) when is_list(X) -> list_to_integer(X);
to_integer(X) when is_binary(X) -> binary_to_integer(X);
to_integer(X) when is_integer(X) -> X;
to_integer(X) -> X.	
