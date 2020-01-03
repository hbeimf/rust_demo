%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. Jan 2020 5:25 PM
%%%-------------------------------------------------------------------
-module(tcpc_common_sup_sup).
-author("mm").

-behaviour(supervisor).

%% API
-export([start_link/1]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").
%%%===================================================================
%%% API functions
%%%===================================================================

%%--------------------------------------------------------------------
%% @doc
%% Starts the supervisor
%%
%% @end
%%--------------------------------------------------------------------
start_link(Params) ->
  supervisor:start_link(?MODULE, [Params]).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
%%
%% @end
%%--------------------------------------------------------------------
-spec(init(Args :: term()) ->
  {ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
    MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
    [ChildSpec :: supervisor:child_spec()]
  }} |
  ignore |
  {error, Reason :: term()}).
init([{PoolId}|_]) ->
  ?LOG(PoolId),
%%  {Ip, Port} = {"127.0.0.1", 8000},
%%  WsAddr = "ws://localhost:5678/ws",
  Addr = tcpc_common:pool_addr(PoolId),
  ?LOG(Addr),
  PoolSpecs = {tcpc_common:pool_name(PoolId),{poolboy,start_link,
    [[{name,{local,tcpc_common:pool_name(PoolId)}},
      {worker_module,tcpc_common_call_actor},
      {size,10},
      {max_overflow,20}],
      [Addr]]},
    permanent,5000,worker,
    [poolboy]},

  Children = [PoolSpecs],

  {ok, {{one_for_one, 10, 10}, Children}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
