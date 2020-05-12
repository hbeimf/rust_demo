%%%-------------------------------------------------------------------
%% @doc app_ex public API
%% @end
%%%-------------------------------------------------------------------

-module(app_ex_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    app_ex_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
