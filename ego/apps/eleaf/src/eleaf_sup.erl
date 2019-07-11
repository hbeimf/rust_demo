%%%-------------------------------------------------------------------
%% @doc rs top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(eleaf_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

-include("log.hrl").
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
      [Ip, Port|_] = explode(Conf, ":"),

      ?LOG({Ip, Port}),

      % RustMonitor = {go_server_monitor, {go_server_monitor, start_link, []},
      % permanent, 5000, worker, [go_server_monitor]},

      PoolSpecs = {leaf_client_pool,{poolboy,start_link,
             [[{name,{local,leaf_client_pool}},
               {worker_module,leaf_client},
               {size,10},
               {max_overflow,20}],
            [Ip, to_integer(Port)]]},
      permanent,5000,worker,
      [poolboy]},


      Children = [PoolSpecs],

      {ok, {{one_for_one, 10, 10}, Children}}.

%%====================================================================
%% Internal functions
%%====================================================================
read_config_file() -> 
  ConfigFile = root_dir() ++ "config.ini",
  ?LOG(ConfigFile),
  case file_get_contents(ConfigFile) of
    {ok, Config} -> 
      zucchini:parse_string(Config);
    _ -> 
      ok
  end.

root_dir() ->
  CmdPath = code:lib_dir(eleaf, priv),
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


  explode(Str, SubStr) ->
    case string:len(Str) of
        Length when Length == 0 ->
            [];
        _Length ->
            explode(Str, SubStr, [])
    end.

explode(Str, SubStr, List) ->
    case string:str(Str, SubStr) of
        Pos when Pos == 0 ->
            List ++ [Str];
        Pos when Pos == 1 ->
            LengthStr = string:len(Str),
            LengthSubStr = string:len(SubStr),
            case LengthStr - LengthSubStr of
                Length when Length =< 0 ->
                    List;
                Length ->
                    LastStr = string:substr(Str, LengthSubStr + 1, Length),
                    explode(LastStr, SubStr, List)
            end;
        Pos ->
            Head = string:substr(Str, 1, Pos -1),
            Tail = string:substr(Str, Pos),
            explode(Tail, SubStr, List ++ [Head])
    end.

to_integer(X) when is_list(X) -> list_to_integer(X);
to_integer(X) when is_binary(X) -> binary_to_integer(X);
to_integer(X) when is_integer(X) -> X;
to_integer(X) -> X.