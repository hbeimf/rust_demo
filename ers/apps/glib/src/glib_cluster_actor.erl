% glib_cluster_actor.erl

%% @hidden
-module(glib_cluster_actor).
-behaviour(gen_server).

-export([start_link/0]).

-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-record(state, {current = #{}}).

% -include("ra.hrl").

%%% machine ets owner

%%%===================================================================
%%% API functions
%%%===================================================================

% create_table(Name, Opts) ->
%     gen_server:call(?MODULE, {new_ets, Name, Opts}).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
	glib_node:connect(),
    {ok, #state{}}.

handle_call(_Msg, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

% make_table(Name, Opts, #state{current = Curr} = State) ->
%     case Curr of
%         #{Name := _} ->
%             % table exists - do nothing
%             State;
%         _ ->
%             _ = ets:new(Name, Opts),
%             State#state{current = Curr#{Name => ok}}
%     end.
