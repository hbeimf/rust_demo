%%%-------------------------------------------------------------------
%% @doc fish_control public API
%% @end
%%%-------------------------------------------------------------------

-module(fish_control_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    fc:load(),
    fish_control_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
