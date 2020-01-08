%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Jan 2020 8:32 PM
%%%-------------------------------------------------------------------
-module(pools_pool_sup).
-author("mm").

-behaviour(supervisor).

%% API
-export([start_link/0]).
-export([start_pool/1]).
-export([children/0]).


%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================
children() ->
  supervisor:which_children(?SERVER).

start_pool(PoolId) ->
  Params = {PoolId},
  supervisor:start_child(?SERVER, [Params]).

%%cleanup(Pid) ->
%%  exit(Pid, shutdown).

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
  RestartStrategy = simple_one_for_one,
  MaxRestarts = 6,
  MaxSecondsBetweenRestarts = 3600,

  SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

  ChildSup = child_sup(pools_sup_sup),

  {ok, {SupFlags, [ChildSup]}}.

%%====================================================================
%% Internal functions
%%====================================================================
%%
%% child(Mod) ->
%% 	Child = {Mod, {Mod, start_link, []},
%%                permanent, 5000, worker, [Mod]},
%%                Child.

%%
%%child_sup(Mod) ->
%%  Child = {Mod, {Mod, start_link, []},
%%    permanent, 5000, supervisor, [Mod]},
%%  Child.

child_sup(Mod) ->
  Child = {Mod, {Mod, start_link, []},
    temporary, 5000, supervisor, [Mod]},
  Child.