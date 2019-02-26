%%%-------------------------------------------------------------------
%% @doc rs top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(rs_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

-include_lib("glib/include/log.hrl").
%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
  {ok, Config} = read_config_file(),
  % ?LOG(Config),
  [{tcp,[{config,Conf}|_]}|_] = Config,
  % ?LOG(Conf),
  [Ip, Port|_] = glib:explode(Conf, ":"),
  % ?LOG(ConfigList),
    % Ip = "127.0.0.1",
    % Port = 12345,

	RustMonitor = {rs_server_monitor, {rs_server_monitor, start_link, []},
		permanent, 5000, worker, [rs_server_monitor]},

         PoolSpecs = {rs_client_pool,{poolboy,start_link,
                 [[{name,{local,rs_client_pool}},
                   {worker_module,rs_client},
                   {size,10},
                   {max_overflow,20}],
        			[Ip, glib:to_integer(Port)]]},
        permanent,5000,worker,
        [poolboy]},


        Children = [RustMonitor, PoolSpecs],

        {ok, {{one_for_one, 10, 10}, Children}}.

%%====================================================================
%% Internal functions
%%====================================================================
read_config_file() -> 
  ConfigFile = root_dir() ++ "config.ini",
  case file_get_contents(ConfigFile) of
    {ok, Config} -> 
      zucchini:parse_string(Config);
    _ -> 
      ok
  end.

root_dir() ->
  CmdPath = code:lib_dir(rs, priv),
  Cmd = lists:concat([CmdPath, "/"]),
  Cmd.
  

file_get_contents(Dir) ->
  case file:read_file(Dir) of
    {ok, Bin} ->
      % {ok, binary_to_list(Bin)};
      {ok, Bin};
    {error, Msg} ->
      {error, Msg}
  end.