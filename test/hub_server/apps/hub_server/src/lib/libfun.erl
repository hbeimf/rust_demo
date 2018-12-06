-module(libfun).

-compile(export_all).

is_pid_alive(Pid) when node(Pid) =:= node() ->
    is_process_alive(Pid);
is_pid_alive(Pid) ->
    case lists:member(node(Pid), nodes()) of
		false ->
	   	 false;
		true ->
	    	case rpc:call(node(Pid), erlang, is_process_alive, [Pid]) of
				true ->
		    		true;
				false ->
		    		false;
				{badrpc, _Reason} ->
		    		false
	    	end
    end.


file_size(Dir) ->
	filelib:file_size(Dir).

file_exists(Dir) ->
	case filelib:is_dir(Dir) of
		true ->
			false;
		false ->
			filelib:is_file(Dir)
	end.

% 时间转时间戳，格式：{{2013,11,13}, {18,0,0}}  
datetime_to_timestamp(DateTime) ->  
	calendar:datetime_to_gregorian_seconds(DateTime) -  calendar:datetime_to_gregorian_seconds({{1970,1,1},{0,0,0}}).  

% 时间戳转时间  
timestamp_to_datetime(Timestamp) ->  
	calendar:gregorian_seconds_to_datetime(Timestamp +  calendar:datetime_to_gregorian_seconds({{1970,1,1},{0,0,0}})).  

get_date() -> 
	T = libfun:time(),
	{{Y, Mon, D}, {H, M, S}} = timestamp_to_datetime(T),
	lists:concat([Y, "-", M, "-" , D, " ", H, ":", M, ":", S]).

%% 获取时间截
time() ->
	DateTime = calendar:local_time(),
	datetime_to_timestamp(DateTime).



root_dir() ->
	replace(os:cmd("pwd"), "\n", "/"). 

append(Dir, Data) ->
	case file_exists(Dir) of
		true ->
			file:write_file(Dir, "\n" ++ Data, [append]);
		_ ->
			file:write_file(Dir, Data, [append])
	end.

replace() -> 
	S = replace("xxx'yyy'zzz", "'", "\\'"),
	io:format("str: ~p ~n ", [S]).

% replace(Str, SubStr, NewStr) ->
% 	case string:str(Str, SubStr) of
% 		Pos when Pos == 0 ->
% 			Str;
% 		Pos when Pos == 1 ->
% 			Tail = string:substr(Str, string:len(SubStr) + 1),
% 			string:concat(NewStr, replace(Tail, SubStr, NewStr));
% 		Pos ->
% 			Head = string:substr(Str, 1, Pos - 1),
% 			Tail = string:substr(Str, Pos + string:len(SubStr)),
% 			string:concat(string:concat(Head, NewStr), replace(Tail, SubStr, NewStr))
% 	end.

replace(Str, SubStr, NewStr) ->
	replace("", Str, SubStr, NewStr). 

replace(Result, Str, SubStr, NewStr) ->
	case string:str(Str, SubStr) of
		Pos when Pos == 0 ->
			string:concat(Result, Str);
		Pos when Pos == 1 ->
			Tail = string:substr(Str, string:len(SubStr) + 1),
			replace(string:concat(Result, NewStr), Tail, SubStr, NewStr);
		Pos ->
			Head = string:substr(Str, 1, Pos - 1),
			Tail = string:substr(Str, Pos + string:len(SubStr)),
			replace(string:concat(Result, string:concat(Head, NewStr)), Tail, SubStr, NewStr)
	end.

implode(List, Str) ->
	string:join(List, Str).

three(Num) ->
    hd(io_lib:format("~.3f",[Num])).

to_str(X) when is_list(X) -> X;
to_str(X) when is_atom(X) -> atom_to_list(X);
to_str(X) when is_binary(X) -> binary_to_list(X);
to_str(X) when is_integer(X) -> integer_to_list(X);
to_str(X) when is_float(X) -> float_to_list(X).

to_binary(X) when is_list(X) -> list_to_binary(X);
to_binary(X) when is_atom(X) -> list_to_binary(atom_to_list(X));
to_binary(X) when is_binary(X) -> X;
to_binary(X) when is_integer(X) -> list_to_binary(integer_to_list(X));
to_binary(X) when is_float(X) -> list_to_binary(float_to_list(X));
to_binary(X) -> term_to_binary(X).

trim(Str) ->
	string:strip(Str).

ltrim(Str) ->
	string:strip(Str, left).

rtrim(Str) ->
	string:strip(Str, right).

trim(Str, SubStr) ->
	LStr = ltrim(Str, SubStr),
	rtrim(LStr, SubStr).

rtrim(Str, SubStr) ->
	NewStr = trim(Str),
	NewSubStr = trim(SubStr),
	LengthNewStr = string:len(NewStr),
	case string:len(NewSubStr) of
		LengthNewSubStr when LengthNewSubStr == 0 ->
			NewStr;
		LengthNewSubStr ->
			case LengthNewStr - LengthNewSubStr of
				Length when Length < 0 ->
					NewStr;
				Length ->
					Head = string:substr(NewStr, Length + 1, LengthNewSubStr),
					case string:equal(Head, NewSubStr) of
						true ->		
							Tail = string:substr(NewStr, 1, Length),
							rtrim(Tail, SubStr);
						false ->
							NewStr
					end
			end
	end.

ltrim(Str, SubStr) ->
	NewStr = trim(Str),
	NewSubStr = trim(SubStr),
	LengthNewStr = string:len(NewStr),
	case string:len(NewSubStr) of
		LengthNewSubStr when LengthNewSubStr == 0 ->
			NewStr;
		LengthNewSubStr ->
			case LengthNewStr - LengthNewSubStr of
				Length when Length < 0 ->
					NewStr;
				Length ->
					Head = string:substr(NewStr, 1, LengthNewSubStr),
					case string:equal(Head, NewSubStr) of
						true ->		
							Tail = string:substr(NewStr, LengthNewSubStr+1, Length),
							ltrim(Tail, SubStr);
						false ->
							NewStr
					end
			end
	end.



