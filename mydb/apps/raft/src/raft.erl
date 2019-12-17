-module(raft).
-compile(export_all).

-include_lib("glib/include/log.hrl").




start() -> 
	%% ErlangNodes = ['tikv1@127.0.0.1', 'tikv2@127.0.0.1', 'tikv3@127.0.0.1'],
	ErlangNodes = glib_node:get_all_nodes(),
	start("MyDBCLuster", ErlangNodes),
	ok.


start(Name, Nodes) ->
    Servers = [{raft_callback, N} || N <- Nodes],
    ra:start_cluster(Name, {module, raft_callback, #{}}, Servers).


test() ->
	% start(),
	?MODULE:members(),
	R1 = ?MODULE:put({raft_callback, 'mydb1@127.0.0.1'}, "MyValue"),
	R2 = ?MODULE:get({raft_callback, 'mydb1@127.0.0.1'}),
	?LOG({R1, R2}),
	ok.

test1() ->
	% start(),
	?MODULE:members(),
	R1 = ?MODULE:put({raft_callback, 'mydb1@127.0.0.1'}, "MyValue"),
	R2 = ?MODULE:get({raft_callback, 'mydb2@127.0.0.1'}),
	?LOG({R1, R2}),
	ok.

members() ->
    members(node()).

members(Node) ->
    case ra:members({raft_callback, Node}) of
	{ok, Result, Leader} -> io:format("Cluster Members:~nLeader:~p~nFollowers:~p~n" ++
					      "Nodes:~p~n", [Leader, lists:delete(Leader, Result), Result]);
	Err -> io:format("Cluster Status error: ~p", [Err])
    end.


put(Server, Value) ->
    case ra:process_command(Server, {put, Value}) of
	{ok, _, _} -> ok;
	Err -> Err
    end.

get(Server) ->
    case ra:process_command(Server, get) of
	{ok, Value, _} ->
	    {ok, Value};
	Err -> Err
    end.

watch(Server) ->
    case ra:process_command(Server, {watch, self()}) of
	{ok, _, _} -> ok;
	Err -> Err
    end.
