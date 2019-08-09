-module(mysqlc_comm).

-compile(export_all).

-include_lib("glib/include/log.hrl").

%% common fun
insert(PoolId, Sql, ParamsList) ->
	% mysql_poolboy:query(pool(), Sql, ParamsList).
	query_pool(pool(PoolId), Sql, ParamsList).


select(PoolId, Sql) ->
	select(PoolId, Sql, []).

select(PoolId, Sql, BindList) ->
	select_from_pool(PoolId, Sql, BindList).

select_from_pool(PoolId, Sql, BindList) ->
	Res = mysql_poolboy:query(pool(PoolId), Sql, BindList),
	parse_res(Res).

query(PoolId, Sql) ->
	query(PoolId, Sql, []).

insert_id(PoolId, Sql) ->
	mysql_poolboy:transaction(pool(PoolId), fun (Pid) ->
	       	Ret = mysql:query(Pid, Sql, []),
		case Ret of
			{error, Msg}->
				glib:write_req({?MODULE, ?LINE, pool(PoolId), Sql, Msg}, "sqlQueryPoolError"),
				error;
			_->
				glib:write_req({?MODULE, ?LINE, pool(PoolId), Sql}, "sqlQueryPoolOk"),
				ok
		end,
		LastInsertId = mysql:insert_id(Pid),
		LastInsertId
	end).


query(PoolId, Sql, ParamsList) ->
	mysql_poolboy:query(pool(PoolId), Sql, ParamsList).

update_sql(TableName, List, Where) ->
	SetList = lists:map(fun({Key, Val}) ->
	            lists:concat(["`", glib:to_str(Key), "` = '", glib:replace(glib:to_str(Val), "'", "\\'"), "'"])
	end, List),
	Set = string:join(SetList, ", "),
	lists:concat(["UPDATE `", TableName, "`", " SET ", Set, " WHERE ", Where]).

pool(PoolId) -> 
	mysqlc_comm_pool_name:pool_name(PoolId).


status(PoolId) ->
	try
		R = test(PoolId),
		% R1 = test_log(),
		% ?LOG({R, R1}),
		status1([R])
	catch
		_K:_Error_msg->
			false
	end.

status1([]) ->
	true;
status1([{error, _}|_Other]) ->
	false;
status1([{ok, _, _}|Other]) ->
	status1(Other).

test(PoolId) -> 
	show_table(pool(PoolId)).

% test_log() -> 
% 	show_table(pool_log()).

show_table(Pool) ->
	Sql = "show tables", 
	query_pool(Pool, Sql).

% insert_user_game_record(Sql) ->
% 	query_pool(pool_log(), Sql).

% insert_user_account_log(Sql) ->
% 	query_pool(pool_log(), Sql).

query_pool(Pool, Sql) ->
	query_pool(Pool, Sql, []).

query_pool(Pool, Sql, ParamsList) ->
	% mysql_poolboy:query(Pool, Sql, ParamsList).
	Ret = mysql_poolboy:query(Pool, Sql, ParamsList),
	case Ret of
		{error, Msg}->
			% ?LOG(Msg),
			% glib:write_log([?MODULE, ?LINE, <<"sql error">>, Sql, Msg]);
			glib:write_req({?MODULE, ?LINE, Pool, Sql, ParamsList, Msg}, "sqlQueryPoolError"),
			error;
		_->
			% ?LOG(query_pool),
			glib:write_req({?MODULE, ?LINE, Pool, Sql, ParamsList}, "sqlQueryPoolOk"),
			ok
	end,
	Ret.

parse_res({ok, KeyList, DataList}) -> 
	RowList = lists:foldl(fun(Data, Res) -> 
		T = lists:zip(KeyList, Data),
		[T|Res]
	end, [], DataList),
	{ok, RowList};
parse_res(_Error) ->  
	{ok, []}.
parse_res({ok, KeyList, DataList}, date)->
	RowList = lists:foldl(fun(Data, Res) -> 
		T = lists:zip(KeyList, Data),
		%?LOG(T),
		%T2 = lists:keymap(format_dates(Data), 2, T),
		T2 = [format_dates(X) || X <- T],
		[T2|Res]
	end, [], DataList),
	{ok, RowList}.

insert_sql(TableName, [List|_] = Rows) ->
	{FieldList, _DataList} = lists:unzip(List),

	FilterFieldList = lists:map(fun(Key) ->
	    glib:to_str(Key)
	end, FieldList),
	FieldStr = string:join(FilterFieldList, "`, `"),

	Vals = lists:map(fun(Row) -> 
		val(Row, FieldList)
	end, Rows),

	ValStr = glib:implode(Vals, ", "),
	lists:concat(["INSERT INTO `", TableName, "` (`", FieldStr, "`) VALUES ", ValStr]).

replace_insert_sql(TableName, [List|_] = Rows) ->
	{FieldList, _DataList} = lists:unzip(List),

	FilterFieldList = lists:map(fun(Key) ->
	    glib:to_str(Key)
	end, FieldList),
	FieldStr = string:join(FilterFieldList, "`, `"),

	Vals = lists:map(fun(Row) -> 
		val(Row, FieldList)
	end, Rows),

	ValStr = glib:implode(Vals, ", "),
	lists:concat(["REPLACE INTO `", TableName, "` (`", FieldStr, "`) VALUES ", ValStr]).


val(Row, FieldList) ->
	ValList = lists:foldr(fun(Field, Reply) -> 
		Val = get_by_key(Field, Row),
		Val1 = glib:replace(glib:to_str(Val), "'", "\\'"),
		Val2 = lists:concat(["'", Val1, "'"]),
		[Val2|Reply]
	end, [], FieldList),

	ValStr = string:join(ValList, ", "),
	Reply = lists:concat(["(", ValStr, ")"]),
	Reply.

get_by_key(Key, TupleList) ->
	case lists:keytake(Key, 1, TupleList) of 
		{_, {_, Val}, _} ->
			Val;
		_ ->
			<<"">>
	end.

format_dates(Data)->
	case Data of 
		{<<"start_time">>, V}->
			{<<"start_time">>, format_dates(merge, V)};
		{<<"end_time">>, V}->
			{<<"end_time">>, format_dates(merge, V)};
		_->
			Data
	end.
format_dates(merge, Data)->
	case Data of
		{{_, _, _}, {_, _, _}}->
			D1 = element(1, Data),
			D2 = element(2, Data),
			%Date = lists:concat([element(1, D1), "-", element(2, D1), "-", element(3, D1), " ", element(1, D2), ":", element(2, D2), ":", element(3, D2)]),
			Month = format_dates(check, element(2, D1)),
			Day = format_dates(check, element(3, D1)),
			Hour =  format_dates(check, element(1, D2)),
			Minth =  format_dates(check, element(2, D2)),
			Second = format_dates(check, element(3, D2)),
			Date = lists:concat([element(1, D1), "-", Month, "-", Day, " ", Hour, ":", Minth, ":", Second]),
			Date2 = glib:to_binary(Date),
			Date2;
		_->
			Data
	end;
format_dates(check, Data)->
	case Data<10 of
		true->
			lists:concat(["0", Data]);
		_->
			Data
	end.




start_pool(PoolConfig) ->
	mysqlc_comm_sup:start_pool(PoolConfig).

stop_pool(PoolConfig) ->
	mysqlc_comm_sup:stop_pool(PoolConfig).

start_pools(PoolConfigList) ->
	lists:foreach(fun(PoolConfig) -> 
        		start_pool(PoolConfig)
    	end, PoolConfigList).	

	
test() ->
    PoolConfigList = [
        #{
            pool_id=>5,
            host=> "127.0.0.1", 
            port=>3306, 
            user=>"root", 
            password=>"123456", 
            database=>"xdb5",
            pool_size => 2
        }
        , #{
            pool_id=>6,
            host=> "127.0.0.1", 
            port=>3306, 
            user=>"root", 
            password=>"123456", 
            database=>"xdb6",
            pool_size=> 5
        }
        , #{
            pool_id=>7,
            host=> "127.0.0.1", 
            port=>3306, 
            user=>"root", 
            password=>"123456", 
            database=>"xdb7"
            % pool_size=> 5
        }

    ],
    lists:foreach(fun(PoolConfig) -> 
        start_pool(PoolConfig)
    end, PoolConfigList).


 test2() ->
 	test(3).
