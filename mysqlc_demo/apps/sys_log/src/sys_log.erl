% sys_log.erl
% glib_log.erl
-module(sys_log).
-compile(export_all).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").

% tt() -> 
% 	lists:foreach(fun(I) -> 
% 		?LOG(I),
% 		test()
% 	end, lists:seq(1, 10)).

test() -> 
	lists:foreach(fun(I) -> 
		?LOG(I),
		test_json(I)
	end, lists:seq(1, 5)).


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
	LogDir = glib:root_dir() ++ "log/" ++ glib:date_str("y-m-d") ++ "-"++ glib:to_str(LogFile) ++"-log.txt",
	% Log = " \n =====================" ++ date_str() ++ "============================ \n " ++ Str,	
	Log = glib:date_str() ++ " => " ++ Json,
	%% 同时写入文件
	append(LogDir, Log).

log_json(Json, LogFile, Day, Time) ->
	LogDir = glib:root_dir() ++ "log/" ++ Day ++ "-"++ glib:to_str(LogFile) ++"-log.txt",
	% Log = " \n =====================" ++ date_str() ++ "============================ \n " ++ Str,	
	Log = Time ++ " - " ++ glib:date_str() ++ " => " ++ Json,
	%% 同时写入文件
	append(LogDir, Log).

log_json(Json, LogFile, Day, Time, Module, Line) ->
	LogDir = glib:root_dir() ++ "log/" ++ Day ++ "-"++ glib:to_str(LogFile) ++"-log.txt",
	% Log = " \n =====================" ++ date_str() ++ "============================ \n " ++ Str,	
	% Log = Time ++ " - " ++ glib:date_str() ++ " => " ++ Json,
	% Log = lists:concat([Module, ":", Line, " <=> ", Time, " - ", glib:date_str(), " <=> ", glib:to_str(Json)]),
	Log = lists:concat([Time, "\t", glib:date_str(), "\t", glib:to_str(sys_log_format:format(Json))]),

	%% 同时写入文件
	append(LogDir, Log).


log_json_in_data(Json, LogFile, Day, Time, Module, Line) ->
	DataDir = glib:root_dir() ++ "log/data/",
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
	Log = lists:concat([Time, "\t", glib:date_str(), "\t", glib:to_str(sys_log_format:format(Json))]),

	%% 同时写入文件
	append(LogDir, Log).

% root_dir() ->
% 	replace(os:cmd("pwd"), "\n", "/"). 

append(Dir, Data) ->
	case glib:file_exists(Dir) of
		true ->
			file:write_file(Dir, "\n" ++ Data, [append]);
		_ ->
			file:write_file(Dir, Data, [append])
	end.