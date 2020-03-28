%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 08. Jan 2020 8:32 PM
%%%-------------------------------------------------------------------
-module(pools_call_sup).
-author("mm").

-behaviour(supervisor).

%% API
-export([start_link/0]).
-export([start_actor/0]).
-export([children/0]).


%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================
children() ->
  supervisor:which_children(?SERVER).

start_actor() ->
  % Params = {},
  supervisor:start_child(?SERVER, []).

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
  MaxRestarts = 0,
  MaxSecondsBetweenRestarts = 1,

  SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

  % ChildSup = child_sup(pools_sup_sup),
  Children = children_list(),

  {ok, {SupFlags, Children}}.

%%====================================================================
%% Internal functions
%%====================================================================

children_list() -> 
	[
		child1(pools_call_actor)
	].

child1(Mod) -> 
  Restart = temporary,
  Shutdown = brutal_kill,
  Type = worker,

  {Mod, {Mod, start_link, []},
    Restart, Shutdown, Type, [Mod]}.


% child(Mod) ->
% 	Child = {Mod, {Mod, start_link, []},
%                permanent, 5000, worker, [Mod]},
%                Child.

%%
%%child_sup(Mod) ->
%%  Child = {Mod, {Mod, start_link, []},
%%    permanent, 5000, supervisor, [Mod]},
%%  Child.

% child_sup(Mod) ->
%   Child = {Mod, {Mod, start_link, []},
%     temporary, 5000, supervisor, [Mod]},
%   Child.