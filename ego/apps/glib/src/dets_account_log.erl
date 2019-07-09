% dets_account_log.erl
-module(dets_account_log).
-compile(export_all).
-define(TABLE, dets_account_log).


-record(account_log, {
	round_id,
	log_str,
             add_time
}).

-include_lib("stdlib/include/qlc.hrl").
-include_lib("glib/include/log.hrl").

% dets_account_log:test().
test() -> 
	open(),
            RoundId = "123456",
            Log = "json string",
            insert(RoundId, Log),
            R = select(RoundId),
            ?LOG(R),
	% close(),
	ok.

test1() ->
    RoundId = "123456",
            Log = "json string",
            insert(RoundId, Log),
            R = select(RoundId),
            ?LOG(R),
    % close(),
    ok.

insert(RoundId, Log) ->
            Time = glib:time(),
	dets:insert(?TABLE, #account_log{round_id=RoundId, log_str=Log, add_time=Time}).

select(RoundId) ->
	case dets:match_object(?TABLE, #account_log{round_id = RoundId, _='_', _='_'}) of
		[{_, RoundId, Log, Time}] -> {ok, Log, Time};
		[] ->{error,not_exist}
	end.

% select()  -> 
%             T = 1554222442,
%             case dets:match_object(?TABLE, #account_log{_ = '_',  _='_', add_time <= T }) of
%                     [{_, RoundId, Log, Time}] -> {ok, RoundId, Log, Time};
%                     [] ->{error,not_exist}
%             end.


select() -> 
    T = 1554222442,
    Rows = select_where(T),
    ?LOG(Rows),
    ok.

select_where(T) -> 
    QH2 = qlc:q([{RoundId, Log, Time} || #account_log{round_id=RoundId, log_str=Log, add_time=Time} <- dets:table(?TABLE), (Time < T)]),
    qlc:info(QH2).



open() ->
	Dir = lists:concat([glib:root_dir(), "dets_table"]),
	glib:make_dir(Dir),
	File = lists:concat([Dir, "/account_log.dets"]),
	open(File).

open(File) ->
    ?LOG({open_dets, File}),

    Bool = filelib:is_file(File),
    %% 使用?MODULE宏获取文件名作为TableName
    case dets:open_file(?TABLE, [{file, File}]) of
        {ok, ?TABLE} ->
            case Bool of
                true  ->void;
                %% 插入键为free, 值为1的记录, 用于统计表中记录的总数
                false ->ok = dets:insert(?TABLE, {free, 1})
            end,
            true;
        {error, Reason} ->
            ?LOG({"cannot open dets table", Reason}),
            false
    end.

close() ->dets:close(?TABLE).

