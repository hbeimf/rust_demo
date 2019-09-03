% glib_log.erl
-module(glib_log).
-compile(export_all).



% % 写系统日志到文件中
% % write_req(Report, Api) ->
% info(Report, Api) ->
% 	make_dir(root_dir() ++ "log"),
% 	Dir = root_dir() ++ "log/cache_"++ random() ++".txt",
% 	{ok, S} = file:open(Dir, write),
% 	io:format(S, "~p~n", [Report]),
% 	file:close(S),
% 	{ok, Str} = file_get_contents(Dir),
% 	req_log(Str, Api),
% 	file:delete(Dir),
% 	ok.


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
	% Log = glib:date_str() ++ ": " ++ Json,
	%% 同时写入文件
	append(LogDir, Json).


% root_dir() ->
% 	replace(os:cmd("pwd"), "\n", "/"). 

append(Dir, Data) ->
	case glib:file_exists(Dir) of
		true ->
			file:write_file(Dir, "\n" ++ Data, [append]);
		_ ->
			file:write_file(Dir, Data, [append])
	end.