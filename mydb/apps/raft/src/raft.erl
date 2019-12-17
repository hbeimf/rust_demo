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
	% ?MODULE:members(),
	% R1 = ?MODULE:put({raft_callback, 'mydb1@127.0.0.1'}, "MyValue"),
	% R2 = ?MODULE:get({raft_callback, 'mydb1@127.0.0.1'}),
	% ?LOG({R1, R2}),
	{Leader, Followers} = leader(),

	?LOG({leader, Leader, followers, Followers}),
	R1 = ?MODULE:put(Leader, "MyValue1"),
	R11 = ?MODULE:get(hd(Followers)),

	% R2 = ?MODULE:put(Leader, "MyValue2"),
	% R22 = ?MODULE:get(hd(Followers)),

	?LOG({R1, R11}),
	ok.

test1() ->
	% start(),
	?MODULE:members(),
	R1 = ?MODULE:put({raft_callback, 'mydb1@127.0.0.1'}, "MyValue"),
	R2 = ?MODULE:get({raft_callback, 'mydb2@127.0.0.1'}),
	?LOG({R1, R2}),
	ok.




leader() ->
    leader(node()).

leader(Node) ->
    case ra:members({raft_callback, Node}) of
		{ok, Result, Leader} -> 
			% io:format("Cluster Members:~nLeader:~p~nFollowers:~p~n" ++
			% 			      "Nodes:~p~n", [Leader, lists:delete(Leader, Result), Result]),
			% case lists:delete(Leader, Result) of 
			% 	[] ->
			% 		{Leader, [Leader]};
			% 	Followers -> 
			% 		{Leader, Followers}
			% end;

			{Leader, followers(Leader)};

		Err -> 
			% io:format("Cluster Status error: ~p", [Err])
			false
    end.

%% 如果没有可用的followers, 则直接用leader 
followers(Leader) -> 
	Nodes = nodes(),
	Nodes1 = [node()|Nodes],
	case Nodes1 of 
		[] -> 
			[Leader];
		_ -> 
			F = lists:foldl(fun(N, Reply) -> 
				[{raft_callback, N}|Reply]
			end, [], Nodes1),
			case lists:delete(Leader, F) of 
				[] ->
					[Leader];
				F1 -> 
					F1
			end
	end.	



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
