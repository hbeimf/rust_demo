-module(glib).
-compile(export_all).

% -export([package/2, unpackage/1, test/0]).

-define( UINT, 32/unsigned-little-integer).
% -define( INT, 32/signed-little-integer).
-define( USHORT, 16/unsigned-little-integer).
% -define( SHORT, 16/signed-little-integer).
% -define( UBYTE, 8/unsigned-little-integer).
% -define( BYTE, 8/signed-little-integer).
	
unpackage(PackageBin) when erlang:byte_size(PackageBin) >= 4 ->
	% io:format("parse package =========~n~n"),
	case parse_head(PackageBin) of
		{ok, PackageLen} ->	
			parse_body(PackageLen, PackageBin);
		Any -> 
			Any
	end;
unpackage(_) ->
	{ok, waitmore}. 

parse_head(<<PackageLen:?UINT ,_/binary>> ) ->
	% io:format("parse head ======: ~p ~n~n", [PackageLen]), 
	{ok, PackageLen};
parse_head(_) ->
	error.

parse_body(PackageLen, _ ) when PackageLen > 9000 ->
	error; 
parse_body(PackageLen, PackageBin) ->
	% io:format("parse body -----------~n~n"),
	case PackageBin of 
		<<RightPackage:PackageLen/binary,NextPageckage/binary>> ->
			<<_Len:?UINT, Cmd:?UINT, DataBin/binary>> = RightPackage,
			% tcp_controller:action(Cmd, DataBin),
			% unpackage(NextPageckage);
			{ok, {Cmd, DataBin}, NextPageckage};
		_ -> {ok, waitmore}
	end.

package(Cmd, DataBin) ->
	Len = byte_size(DataBin)+8,
	<<Len:?UINT, Cmd:?UINT, DataBin/binary>>.


test() -> 
	B = package(123, <<"hello world!">>),
	unpackage(B).


% glib:uid().
uid() -> 
	esnowflake:generate_id().



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
	lists:concat([Y, "-", Mon, "-" , D, " ", H, ":", M, ":", S]).

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


explode(Str, SubStr) ->
    case string:len(Str) of
        Length when Length == 0 ->
            [];
        _Length ->
            explode(Str, SubStr, [])
    end.

explode(Str, SubStr, List) ->
    case string:str(Str, SubStr) of
        Pos when Pos == 0 ->
            List ++ [Str];
        Pos when Pos == 1 ->
            LengthStr = string:len(Str),
            LengthSubStr = string:len(SubStr),
            case LengthStr - LengthSubStr of
                Length when Length =< 0 ->
                    List;
                Length ->
                    LastStr = string:substr(Str, LengthSubStr + 1, Length),
                    explode(LastStr, SubStr, List)
            end;
        Pos ->
            Head = string:substr(Str, 1, Pos -1),
            Tail = string:substr(Str, Pos),
            explode(Tail, SubStr, List ++ [Head])
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

to_integer(X) when is_list(X) -> list_to_integer(X);
to_integer(X) when is_binary(X) -> binary_to_integer(X);
to_integer(X) when is_integer(X) -> X;
to_integer(X) -> X.	

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

md5(S, true) ->
	string:substr(md5(S), 9, 16).

md5(S) ->
    Md5_bin =  erlang:md5(S),
    Md5_list = binary_to_list(Md5_bin),
    lists:flatten(list_to_hex(Md5_list)).

list_to_hex(L) ->
    lists:map(fun(X) -> int_to_hex(X) end, L).

int_to_hex(N) when N < 256 ->
    [hex(N div 16), hex(N rem 16)].

hex(N) when N < 10 ->
    $0+N;
hex(N) when N >= 10, N < 16 ->
    $a + (N-10).


token() ->
	T = md5(to_str(uid())),
	B = to_binary(T),
	binary:part(B, 0, 10).

http_get(Url) ->
    case httpc:request(get, {to_str(Url), []},
                        [{autoredirect, true},
                         {timeout, 60000},
                         {version, "HTTP/1.1"}],
                        [{body_format, binary}]) of
            {ok, {_,_, Body}}->
                Body;
            {error, _Reason} ->
                <<"">>
    end.

file_get_contents(Dir) ->
    case file:read_file(Dir) of
        {ok, Bin} ->
            {ok, binary_to_list(Bin)};
        {error, Msg} ->
            {error, Msg}
    end.

file_put_contents(Dir, Str) ->
    file:write_file(Dir, to_binary(Str)).

is_dir(Dir) ->
    filelib:is_dir(Dir).

make_dir(Dir) ->
    file:make_dir(Dir).

del_dir(Dir) ->
    file:del_dir(Dir).


% =====================================

get_ip() -> 
	{ok, L} = inet:getif(),
	lists:foldl(fun({Ip, _, _}, Reply) -> 
		[Ip|Reply]
	end, [], L).
