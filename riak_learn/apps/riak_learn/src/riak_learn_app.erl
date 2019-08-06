-module(riak_learn_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    case riak_learn_sup:start_link() of
        {ok, Pid} ->
            ok = riak_core:register([{vnode_module, riak_learn_vnode}]),
            ok = riak_core_node_watcher:service_up(riak_learn, self()),

            {ok, Pid};
        {error, Reason} ->
            {error, Reason}
    end.

stop(_State) ->
    ok.
