%%%-------------------------------------------------------------------
%% @doc raft public API
%% @end
%%%-------------------------------------------------------------------

-module(raft_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    raft_callback:start(),
    raft_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
