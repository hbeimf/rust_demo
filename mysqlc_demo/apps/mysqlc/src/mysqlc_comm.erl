-module(mysqlc_comm).

%% API
% -export([start_link/0]).

-compile(export_all).

-include_lib("glib/include/log.hrl").

% insert(Sql, ParamsList) ->
% 	insert(pool1, Sql, ParamsList).
% insert(Pool, Sql, ParamsList) ->
% 	mysql_poolboy:query(Pool, Sql, ParamsList). 


% CREATE TABLE `user` (
%   `aid` int(11) NOT NULL AUTO_INCREMENT,
%   `id` varchar(64) DEFAULT NULL,
%   `username` varchar(32) NOT NULL,
%   `password` varchar(64) NOT NULL,
%   `nickname` varchar(32) NOT NULL,
%   `channel_id` varchar(16) NOT NULL,
%   `sub_channel_id` varchar(32) DEFAULT NULL COMMENT '子渠道标识',
%   `platform` varchar(16) DEFAULT NULL,
%   `private_key` varchar(32) NOT NULL,
%   `sns_from` varchar(8) NOT NULL,
%   `sns_id` varchar(32) NOT NULL,
%   `sns_ext_id` varchar(64) DEFAULT NULL COMMENT 'sns扩展id，uni_id或者openid',
%   `icon` varchar(256) DEFAULT '',
%   `gold` bigint(20) DEFAULT NULL,
%   `valid_gold` bigint(20) DEFAULT NULL COMMENT '打码量，小于等于gold字段',
%   `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
%   `invite_code` varchar(4) DEFAULT NULL COMMENT '推荐码',
%   `status` int(11) NOT NULL COMMENT '1:可用 0：禁用',
%   PRIMARY KEY (`aid`),
%   UNIQUE KEY `username` (`username`),
%   UNIQUE KEY `id` (`id`),
%   KEY `sf_password` (`password`),
%   KEY `sf_status` (`status`),
%   KEY `sf_sns_from` (`sns_from`),
%   KEY `sf_sns_id` (`sns_id`)
% ) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4;

% insert_user(UserName, Nickname, Platform, Channel_id, Sub_channel_id, Icon) ->
% 	%% 先搞几个默认值，逻辑清楚了再重新初始化
% 	PassWord = glib:md5(glib:to_str(glib:uid())),
% 	Private_key = glib:to_str(glib:uid()),
% 	Sns_from = "",
% 	Sns_id = "",
% 	Status = 1,
% 	Id = UserName,

% 	Invite_code = glib:to_str(glib:uid()),

% 	CurrentTime = glib:date_str(),

% 	Sql = "INSERT INTO user (id, username, password, private_key, sns_from, sns_id, nickname, platform, channel_id, sub_channel_id,  icon, status, gold, valid_gold, invite_code, create_time) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
	
% 	insert(Sql, [Id, UserName, PassWord, Private_key, Sns_from, Sns_id, Nickname, Platform, Channel_id, Sub_channel_id, Icon, Status, 0, 0, Invite_code, CurrentTime]).



% all_game() -> 
% 	Sql = "select id, status, order_id, default_flag from game",
% 	case select(Sql, []) of 
% 		{ok, GameList} -> 
% 			GameList;
% 		_ -> 
% 			[]
% 	end.

% % mysqlc:all_channel().
% all_channel() -> 
% 	Sql = "select id from channel",
% 	case select(Sql, []) of 
% 		{ok, ChannelList} -> 
% 			ChannelList;
% 		_ -> 
% 			[]
% 	end.


% channel_info_by_channel_name(ChannelName) ->
% 	Sql = "select * from channel where channel_name = ? limit 1",
% 	case select(Sql, [ChannelName]) of 
% 		{ok, [Row|_]} -> 
% 			Row;
% 		_ -> 
% 			[]
% 	end.

% game_channel_info() ->
% 	Id = 1,
% 	game_channel_info(Id).
% game_channel_info(Id) ->
% 	Sql = "select * from game_channel where id = ? limit 1",
% 	case select(Sql, [Id]) of 
% 		{ok, [Row|_]} -> 
% 			Row;
% 		_ -> 
% 			[]
% 	end.


% % mysqlc:channel_info().
% channel_info()->
% 	channel_info(1).
% channel_info(Channel_id) ->
% 	Sql = "select * from channel where id = ? limit 1",
% 	Info = select(Sql, [Channel_id]),
% 	% ?LOG({info, Info}),
% 	Info.

% user_info() ->
% 	user_info(<<"test">>).
% user_info(UserName) ->
% 	Sql = "select * from user where username = ? limit 1",
% 	User = select(Sql, [UserName]),
% 	User.

% game_info() -> 
% 	GameId = 1,
% 	game_info(GameId).
% game_info(GameId) ->
% 	Sql = "select * from game where id = ? limit 1",
% 	case select(Sql, [GameId]) of 
% 		{ok, [Row|_]} -> 
% 			Row;
% 		_ -> 
% 			[]
% 	end.


%% common fun
insert(Sql, ParamsList) ->
	% mysql_poolboy:query(pool(), Sql, ParamsList).
	query_pool(pool(), Sql, ParamsList).


select(Sql) ->
	select(Sql, []).

select(Sql, BindList) ->
	select_from_pool(Sql, BindList).

select_from_pool(Sql, BindList) ->
	Res = mysql_poolboy:query(pool(), Sql, BindList),
	parse_res(Res).

query(Sql) ->
	query(Sql, []).

insert_id(Sql) ->
	mysql_poolboy:transaction(pool(), fun (Pid) ->
	       	Ret = mysql:query(Pid, Sql, []),
		case Ret of
			{error, Msg}->
				glib:write_req({?MODULE, ?LINE, pool(), Sql, Msg}, "sqlQueryPoolError"),
				{error, Msg};
			_->
				glib:write_req({?MODULE, ?LINE, pool(), Sql}, "sqlQueryPoolOk"),
				ok
		end,
		LastInsertId = mysql:insert_id(Pid),
		LastInsertId
	end).


query(Sql, ParamsList) ->
	mysql_poolboy:query(pool(), Sql, ParamsList).

update_sql(TableName, List, Where) ->
	SetList = lists:map(fun({Key, Val}) ->
	            lists:concat(["`", glib:to_str(Key), "` = '", glib:replace(glib:to_str(Val), "'", "\\'"), "'"])
	end, List),
	Set = string:join(SetList, ", "),
	lists:concat(["UPDATE `", TableName, "`", " SET ", Set, " WHERE ", Where]).

pool() -> 
	pool.

% pool_log() -> 
% 	pool_log.

status() ->
	try
		R = test(),
		% R1 = test_log(),
		% ?LOG({R, R1}),
		status([R])
	catch
		K:Error_msg->
			false
	end.

status([]) ->
	true;
status([{error, _}|Other]) ->
	false;
status([{ok, _, _}|Other]) ->
	status(Other).

test() -> 
	show_table(pool()).

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
			{error, Msg};
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
	{FieldList, DataList} = lists:unzip(List),

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
	{FieldList, DataList} = lists:unzip(List),

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

% get_game_record({Uid, Game_id, Limit})->
% 	Sql = "select * from user_game_record where user_id=? and game_id= ? order by id desc limit ? ",
% 	Ret = mysql_poolboy:query(pool_log(), Sql,  [Uid, Game_id, Limit]),
% 	case Ret of
% 		{ok,_,_}->
% 			Ret2 = parse_res(Ret ,date);
% 		_->
% 			Ret
% 	end.

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
