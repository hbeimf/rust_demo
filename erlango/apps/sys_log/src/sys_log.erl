% sys_log.erl
% glib_log.erl
-module(sys_log).
-compile(export_all).

% -include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").

% tt() -> 
% 	lists:foreach(fun(I) -> 
% 		?LOG(I),
% 		test()
% 	end, lists:seq(1, 10)).


% test() -> 
% 	lists:foreach(fun(I) -> 
% 		?LOG(I),
% 		test_json(I)
% 	end, lists:seq(1, 5)).


tt() -> 
	
	Base_num = 10000,
	lists:foreach(fun(Index) -> 
		Rand = glib:random_number(Base_num),
		?WRITE_LOG("rand_num_new", {Index, Rand}),
		ok
	end, lists:seq(1, 100000)),
	
	ok.

test() -> 
	lists:foreach(fun(I) -> 
		% ?LOG(I),
		test_json(I)
	end, [1]).

test_json(Index) ->
	Data = [
	        {<<"user_name">>, unicode:characters_to_binary("小强")}
	        , {<<"password">>, <<"a123456">>}
	        , {<<"index">>, Index}

	    ],
	Json = jsx:encode(Data),
	LogFile = "test_json_log",
	% write_json(LogFile, Json).
	?WRITE_JSON(LogFile, Json),
	
	?WRITE_LOG("test_erlang_ds", Data),

	ok.

write_json(Module, Line, LogFile, Json) ->
	% write_line(Module, Line, LogFile, Json).
	Day = glib:date_str("y-m-d"),
	Time = glib:date_str(),

	{ok, Pid} = sys_log_sup:start_child(LogFile),
	sys_log_worker:log_json(Pid, Json, Day, Time, Module, Line).

	
write_line(Module, Line, LogFile, Json) ->
	Day = glib:date_str("y-m-d"),
	Time = glib:date_str(),

	{ok, Pid} = sys_log_sup:start_child(LogFile),
	sys_log_worker:log(Pid, Json, Day, Time, Module, Line).

	
% log_json() ->
% 	Data = [
% 	        {<<"user_name">>, unicode:characters_to_binary("小强")}
% 	        , {<<"password">>, <<"a123456">>}
% 	    ],
% 	Json = jsx:encode(Data),

% 	log_json(Json, "test_json_info").

log_json(Json, LogFile) ->
	LogDir = glib:log_dir() ++ "log/" ++ glib:date_str("y-m-d") ++ "-"++ glib:to_str(LogFile) ++"-log.txt",
	% Log = " \n =====================" ++ date_str() ++ "============================ \n " ++ Str,	
	Log = glib:date_str() ++ " => " ++ Json,
	%% 同时写入文件
	append(LogDir, Log).

log_json(Json, LogFile, Day, Time) ->
	LogDir = glib:log_dir() ++ "log/" ++ Day ++ "-"++ glib:to_str(LogFile) ++"-log.txt",
	% Log = " \n =====================" ++ date_str() ++ "============================ \n " ++ Str,	
	Log = Time ++ " - " ++ glib:date_str() ++ " => " ++ Json,
	%% 同时写入文件
	append(LogDir, Log).

log_json(Json, LogFile, Day, Time, Module, Line) ->
	LogDir = glib:log_dir() ++ "log/" ++ Day ++ "-"++ glib:to_str(LogFile) ++"-log.txt",

	Data = [
		% {<<"term">>, glib:to_binary(glib:to_str(sys_log_format:format(Json)))}
		{<<"term">>, Json}
		, {<<"module">>, Module}
		, {<<"line">>, Line}
		, {<<"receive_time">>, glib:to_binary(Time)}
		, {<<"write_time">>, glib:to_binary(glib:date_str())}
	],
	Log = jsx:encode(Data),

	%% 同时写入文件
	append(LogDir, Log).


log_json_in_data(Json, LogFile, Day, _Time, _Module, _Line) ->
	DataDir = glib:log_dir() ++ "log/data/",
	case glib:is_dir(DataDir) of
		false -> 
			glib:make_dir(DataDir);
		_ -> 
			ok
	end, 

	LogDir = DataDir ++ Day ++ "-"++ glib:to_str(LogFile) ++"-log.txt",
	% Log = " \n =====================" ++ date_str() ++ "============================ \n " ++ Str,	
	% Log = Time ++ " - " ++ glib:date_str() ++ " => " ++ Json,
	% Log = lists:concat([Module, ":", Line, " <=> ", Time, " - ", glib:date_str(), " <=> ", glib:to_str(Json)]),
	% Log = lists:concat([glib:to_str(sys_log_format:format(Json))]),

	%% 同时写入文件
	append(LogDir, Json).

% log_dir() ->
% 	replace(os:cmd("pwd"), "\n", "/"). 

append(Dir, Data) ->
	append(jsx:is_json(Data), Dir, Data).

append(true, Dir, Data) ->
	case glib:file_exists(Dir) of
		true ->
			file:write_file(Dir, "\n" ++ Data, [append, raw]);
		_ ->
			file:write_file(Dir, Data, [append, raw])
	end;
append(_, Dir, Data) ->
	{ok, S} = file:open(Dir, write),
    io:format(S, "~p.~n", [Data]),
    file:close(S).




