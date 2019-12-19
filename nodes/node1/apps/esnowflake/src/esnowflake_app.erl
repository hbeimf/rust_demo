%% @doc esnowflake application API
%% @end

-module(esnowflake_app).

-behaviour(application).

-include("esnowflake.hrl").

%% Application callbacks
-export([start/2, stop/1]).

start(_StartType, StartArgs) ->
    [MinId, MaxId] = application:get_env(esnowflake, worker_min_max_id, ?DEFAULT_WORKER_MIN_MAX),

    ?LOG({MinId, MaxId}),
    Version = proplists:get_value(vsn, StartArgs),
    ?LOG({version, Version}),

    %% 先启动框架
    {ok, Pid} = esnowflake_sup:start_link(Version),

    ?LOG({start_work_actor}),
    %% 在框架里启动具体的工作actor
    Pids = [{Wid, esnowflake_worker_pool:spawn_worker(Wid)} || Wid <- lists:seq(MinId, MaxId)],
    ?LOG(Pids),

    {ok, Pid}.

stop(_State) ->
    ok.
