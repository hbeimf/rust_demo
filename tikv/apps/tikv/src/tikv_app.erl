%%%-------------------------------------------------------------------
%% @doc tikv public API
%% @end
%%%-------------------------------------------------------------------

-module(tikv_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	refcell:start(),
    tikv_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
