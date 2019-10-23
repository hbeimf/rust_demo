-module(mysqlc_comm_construct_sql).

-compile(export_all).

-include_lib("glib/include/log.hrl").



insert_sql(TableName, [List|_] = Rows) ->
	{FieldList, DataList} = lists:unzip(List),

	FilterFieldList = lists:map(fun(Key) ->
	    glib:to_binary(Key)
	end, FieldList),
	FieldBin = merge_binary_list(FilterFieldList, <<"`, `">>),

	Vals = lists:map(fun(Row) -> 
		val(Row, FieldList)
	end, Rows),

	ValBin = merge_binary_list(Vals, <<", ">>),

	Sql = merge_binary_list([<<"INSERT INTO `">>, glib:to_binary(TableName), <<"` (`">>, FieldBin, <<"`) VALUES ">>, ValBin]),
	Sql.


replace_insert_sql(TableName, [List|_] = Rows) ->
	{FieldList, DataList} = lists:unzip(List),

	FilterFieldList = lists:map(fun(Key) ->
	    glib:to_binary(Key)
	end, FieldList),
	FieldBin = merge_binary_list(FilterFieldList, <<"`, `">>),

	Vals = lists:map(fun(Row) -> 
		val(Row, FieldList)
	end, Rows),

	ValBin = merge_binary_list(Vals, <<", ">>),
	Sql = merge_binary_list([<<"REPLACE INTO `">>, glib:to_binary(TableName), <<"` (`">>, FieldBin, <<"`) VALUES ">>, ValBin]),
	% ?LOG(Sql),
	Sql.

val(Row, FieldList) ->
	ValList = lists:foldr(fun(Field, Reply) -> 
		Val = get_by_key(Field, Row),
		List = [<<"'">>, binary_replace(Val), <<"'">>],
		Val2 = merge_binary_list(List),
		case Reply of 
			[] -> 
				[Val2|Reply];
			_ -> 
				[Val2, <<", ">>|Reply]
		end
	end, [], FieldList),

	ValBin = merge_binary_list(ValList),

	Reply = merge_binary_list([<<"(">>, ValBin, <<")">>]),
	% ?LOG({ValBin, Reply}),
	Reply.


%% 替换单引号
% mysqlc:test_binary_replace().
test_binary_replace() ->
	Bin = <<"abc'de">>,
	Bin1 = binary_replace(Bin),
	?LOG(Bin1),
	ok.

binary_replace(Bin) ->
	binary:replace(glib:to_binary(Bin),<<"'">>,<<"\\'">>, [global]).

% mysqlc:test_merge_binary_list().
test_merge_binary_list() ->
	List = [<<"a">>, <<"b">>, <<"c">>],
	R1 = merge_binary_list(List),
	R2 = merge_binary_list(List, <<", ">>),
	?LOG({R1, R2}),
	ok.

merge_binary_list(List, Gap) ->
	List1 = lists:foldl(fun(Bin, Reply) -> 
		case Reply of 
			[] ->
				[Bin|Reply];
			_ -> 	
				[Bin, glib:to_binary(Gap)|Reply]
		end
	end, [], List),
	merge_binary_list(List1).

merge_binary_list(List) ->
	lists:foldl(fun(Bin, Reply) -> 
		merge_binary(Reply, Bin)
	end, <<>>, List).

merge_binary(Bin1, Bin2) -> 
	<<Bin1/binary, Bin2/binary>>.

% mysqlc_comm_construct_sql:tt().
tt() -> 
	Rows = [
		[{<<"user_id">>, <<49,95,230,181,139,232,175,149,95,49,50,49,50,49>>}, {<<"game_id">>, <<"1001">>}]
		, [{<<"user_id">>, <<"test123">>}, {<<"game_id">>, <<"1001">>}]
		, [{<<"user_id">>, unicode:characters_to_binary("测试")}, {<<"game_id">>, <<"1001">>}]
		, [{<<"user_id">>, unicode:characters_to_binary("测试'注入''!!!")}, {<<"game_id">>, <<"1001">>}]

		],

	Sql = replace_insert_sql("test_table_name", Rows),
	?LOG(Sql),
	io:format("sql: ~ts~n", [Sql]),


	Sql1 = insert_sql("test_table", Rows),
	?LOG(Sql1),
	io:format("sql: ~ts~n", [Sql1]),
	ok.


get_by_key(Key, TupleList) ->
	case lists:keytake(Key, 1, TupleList) of 
		{_, {_, Val}, _} ->
			Val;
		_ ->
			<<"">>
	end.