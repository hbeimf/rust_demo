-module(pp).
-compile(export_all).

% -export([package/2, unpackage/1, test/0]).

-define( UINT, 32/unsigned-little-integer).
% -define( INT, 32/signed-little-integer).
-define( USHORT, 16/unsigned-little-integer).
% -define( SHORT, 16/signed-little-integer).
% -define( UBYTE, 8/unsigned-little-integer).
% -define( BYTE, 8/signed-little-integer).
-include_lib("glib/include/log.hrl").





% % sys_config:reload().
% reload() ->
% 	case read_config_file() of
% 		{ok, ConfigList} -> 
% 			% Aes = {aes,[{key,go:aes_key()}]},
% 			% ConfigList1 = [Aes|ConfigList],

% 			lists:foreach(fun({Key, Val}) -> 
% 				ets:insert(?SYS_CONFIG, #sys_config{key=Key, val=Val})
% 			end, ConfigList),
% 			ok;
% 		_ -> 
% 			ok
% 	end,
% 	ok.

test() -> 
	read_config_file().

tt() -> 
	ConfigFile = root_dir() ++ "config/config.ini",
	case file_get_contents(ConfigFile) of
		{ok, Config} -> 
			zucchini:parse_string(Config);
		_ -> 
			ok
	end.

read_config_file() -> 
	ConfigFile = root_dir() ++ "config.ini",
	case file_get_contents(ConfigFile) of
		{ok, Config} -> 
			zucchini:parse_string(Config);
		_ -> 
			ok
	end.

root_dir() ->
	replace(os:cmd("pwd"), "\n", "/"). 

file_get_contents(Dir) ->
	case file:read_file(Dir) of
		{ok, Bin} ->
			% {ok, binary_to_list(Bin)};
			{ok, Bin};
		{error, Msg} ->
			{error, Msg}
	end.

replace(Str, SubStr, NewStr) ->
	case string:str(Str, SubStr) of
		Pos when Pos == 0 ->
			Str;
		Pos when Pos == 1 ->
			Tail = string:substr(Str, string:len(SubStr) + 1),
			string:concat(NewStr, replace(Tail, SubStr, NewStr));
		Pos ->
			Head = string:substr(Str, 1, Pos - 1),
			Tail = string:substr(Str, Pos + string:len(SubStr)),
			string:concat(string:concat(Head, NewStr), replace(Tail, SubStr, NewStr))
	end.
