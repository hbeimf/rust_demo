%%%-------------------------------------------------------------------
%% @doc sys_log top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(sys_log_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

-export([start_child/1, close_child/1]).
-export([children/0, work_id/1]).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

children() -> 
    Children = supervisor:which_children(?SERVER),
    Children.

% sys_log_sup:start_child("log_test").
% sys_log_sup:start_child("log_test").
start_child(LogFile) ->
	case try_start_child(LogFile) of 
		{error,{already_started,Pid}} ->
			{ok, Pid};
		Reply -> 
			Reply
	end.

try_start_child(LogFile) ->
	case sys_log_ets:get_config(LogFile) of
		{ok, Pid} -> 
			case erlang:is_pid(Pid) andalso glib:is_pid_alive(Pid) of 
				true -> 
					{ok, Pid};
				_ -> 
					WorkerId = work_id(LogFile),
					    MysqlcConnSup =  {WorkerId, {sys_log_worker, start_link, [LogFile]},
					               temporary, 5000, worker, [sys_log_worker]},
					    supervisor:start_child(?SERVER, MysqlcConnSup)
			end;
		_ ->  
			    WorkerId = work_id(LogFile),
			    MysqlcConnSup =  {WorkerId, {sys_log_worker, start_link, [LogFile]},
			               temporary, 5000, worker, [sys_log_worker]},
			    supervisor:start_child(?SERVER, MysqlcConnSup)
	end.




close_child(LogFile) ->
    WorkerId = work_id(LogFile),
    Result = supervisor:terminate_child(?SERVER, WorkerId),
    % ?LOG({Result}),
    Result.  


work_id(LogFile) ->
        lists:concat(["log_worker_", LogFile]).


%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
% init([]) ->
%     {ok, { {one_for_one, 0, 1}, []} }.

init([]) ->
    Ets = {sys_log_ets, {sys_log_ets, start_link, []},
               permanent, 5000, worker, [sys_log_ets]},
              
      Children = [Ets],
    {ok, { {one_for_one, 10, 10}, Children} }.

%%====================================================================
%% Internal functions
%%====================================================================
