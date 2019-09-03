% sys_log.erl
% glib_log.erl
-module(sys_log).
-compile(export_all).


json() ->
	Data = [
	        {<<"user_name">>, unicode:characters_to_binary("小强")}
	        , {<<"password">>, <<"a123456">>}
	    ],
	Json = jsx:encode(Data),
	LogFile = "test_json_log",
	json(LogFile, Json).
	
json(LogFile, Json) ->
	{ok, Pid} = sys_log_sup:start_child(LogFile),
	sys_log_worker:log(Pid, Json).

	
log_json() ->
	Data = [
	        {<<"user_name">>, unicode:characters_to_binary("小强")}
	        , {<<"password">>, <<"a123456">>}
	    ],
	Json = jsx:encode(Data),

	log_json(Json, "test_json_info").

log_json(Json, LogFile) ->
	LogDir = glib:root_dir() ++ "log/" ++ glib:date_str("y-m-d") ++ "-"++ glib:to_str(LogFile) ++"-log.txt",
	% Log = " \n =====================" ++ date_str() ++ "============================ \n " ++ Str,	
	Log = glib:date_str() ++ " => " ++ Json,
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