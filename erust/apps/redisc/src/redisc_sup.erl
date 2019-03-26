%%%-------------------------------------------------------------------
%% @doc redis top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(redisc_sup).

-behaviour(supervisor).

%% Include
-include_lib("eunit/include/eunit.hrl").
-include("log.hrl").

%% API
-export([start_link/0, start_link/2]).
-export([create_pool/3, delete_pool/1]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    % Pools = rconf:read_config(redis),
    Pools = get_pools(),
    {ok, GlobalOrLocal} = application:get_env(redisc, global_or_local),
    start_link(Pools, GlobalOrLocal).

start_link(Pools, GlobalOrLocal) ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, [Pools, GlobalOrLocal]).

%% ===================================================================
%% @doc create new pool.
%% @end
%% ===================================================================
-spec(create_pool(PoolName::atom(), Size::integer(), Options::[tuple()]) ->
             {ok, pid()} | {error,{already_started, pid()}}).

create_pool(PoolName, Size, Options) ->
    create_pool(local, PoolName, Size, Options).

%% ===================================================================
%% @doc create new pool, selectable name zone global or local.
%% @end
%% ===================================================================
-spec(create_pool(GlobalOrLocal::atom(), PoolName::atom(), Size::integer(), Options::[tuple()]) ->
             {ok, pid()} | {error,{already_started, pid()}}).

create_pool(GlobalOrLocal, PoolName, Size, Options)
  when GlobalOrLocal =:= local;
       GlobalOrLocal =:= global ->

    SizeArgs = [{size, Size}, {max_overflow, 10}],
    PoolArgs = [{name, {GlobalOrLocal, PoolName}}, {worker_module, eredis}],
    PoolSpec = poolboy:child_spec(PoolName, PoolArgs ++ SizeArgs, Options),

    supervisor:start_child(?MODULE, PoolSpec).

%% ===================================================================
%% @doc delet pool and disconnected to Redis.
%% @end
%% ===================================================================
-spec(delete_pool(PoolName::atom()) -> ok | {error,not_found}).

delete_pool(PoolName) ->
    supervisor:terminate_child(?MODULE, PoolName),
    supervisor:delete_child(?MODULE, PoolName).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([Pools, GlobalOrLocal]) ->
    ?LOG(Pools),
    RestartStrategy = one_for_one,
    MaxRestarts = 10,
    MaxSecondsBetweenRestarts = 10,

    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

    PoolSpecs = lists:map(fun({Name, SizeArgs, WorkerArgs}) ->
        PoolArgs = [{name, {GlobalOrLocal, Name}},
                    {worker_module, eredis}] ++ SizeArgs,
        poolboy:child_spec(Name, PoolArgs, WorkerArgs)
    end, Pools),

    io:format("~n ===============redis spec: ~n~p~n", [PoolSpecs]),

    {ok, {SupFlags, PoolSpecs}}.


get_pools() -> 
    case  sys_config:get_config(redis) of
        {ok, Redis} -> 
            % {_, {redis, Redis}, _ } = lists:keytake(redis, 1, Config),
            {_, {host, Host}, _} = lists:keytake(host, 1, Redis),
            {_, {port, Port}, _} = lists:keytake(port, 1, Redis),
            % Database = 10,
            {_, {select, Database}, _} = lists:keytake(select, 1, Redis),
            
            % {_, {password, Password}, _} = lists:keytake(password, 1, Redis),
            case lists:keytake(password, 1, Redis) of
                {_, {password, Password}, _} -> 
                    [{pool_redis,
                        [{size,30},{max_overflow,20}], 
                        [{host,Host},
                            {port,to_integer(Port)},
                            {password, Password},
                            {database, to_integer(Database)},
                            {reconnect_sleep,100}]}];
                _ -> 
                    [{pool_redis,
                        [{size,30},{max_overflow,20}], 
                        [{host,Host},
                            {port,to_integer(Port)},
                            {database, to_integer(Database)},
                            {reconnect_sleep,100}]}]
            end;
            
        _ -> 
            ok
    end.

to_integer(X) when is_list(X) -> list_to_integer(X);
to_integer(X) when is_binary(X) -> binary_to_integer(X);
to_integer(X) when is_integer(X) -> X;
to_integer(X) -> X.