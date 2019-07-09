-module(lib_fun).
-compile(export_all).
% -include("config.hrl").



ceil(N) ->
    T = trunc(N),
    case N == T of
        true  -> T;
        false -> 1 + T
    end.

get_body(TemplateName, DataList, Handler) ->
	%TemplateDir = code:priv_dir(http_serv) ++ "/" ++ TemplateName,
	%TemplateDir = http_serv_fun:priv_dir() ++ TemplateName,
	case code:priv_dir(http_serv) of
		{error,bad_name} ->
			TemplateDir = go_lib:priv_dir() ++ TemplateName;
		Dir ->
			TemplateDir = Dir ++ "/" ++ TemplateName
	end,
	erlydtl:compile( TemplateDir, Handler, [
		{out_dir, false},
	 	{custom_filters_modules, [lib_filter]},
	 	{custom_tags_modules, [lib_tags]}
	]),
	{ok, List} = Handler:render(DataList),
	iolist_to_binary(List).

to_list(S) when is_integer(S) ->
	integer_to_list(S);
to_list(S) when is_float(S) ->
	float_to_list(S);
to_list(S) ->
	S.

%% lib_file
append(Dir, Data) ->
	case file_exists(Dir) of
		true ->
			file:write_file(Dir, "\n" ++ Data, [append]);
		_ ->
			file:write_file(Dir, Data, [append])
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

file_exists(Dir) ->
	case filelib:is_dir(Dir) of
		true ->
			false;
		false ->
			filelib:is_file(Dir)
	end.

is_dir(Dir) ->
	filelib:is_dir(Dir).

make_dir(Dir) ->
	file:make_dir(Dir).

del_dir(Dir) ->
	file:del_dir(Dir).

file_size(Dir) ->
	filelib:file_size(Dir).

%% lib_fun
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

to_binary(X) when is_list(X) -> list_to_binary(X);
to_binary(X) when is_atom(X) -> list_to_binary(atom_to_list(X));
to_binary(X) when is_binary(X) -> X;
to_binary(X) when is_integer(X) -> list_to_binary(integer_to_list(X));
to_binary(X) when is_float(X) -> list_to_binary(float_to_list(X));
to_binary(X) -> term_to_binary(X).

to_str(X) when is_list(X) -> X;
to_str(X) when is_atom(X) -> atom_to_list(X);
to_str(X) when is_binary(X) -> binary_to_list(X);
to_str(X) when is_integer(X) -> integer_to_list(X);
to_str(X) when is_float(X) -> float_to_list(X).


to_integer(X) when is_list(X) -> list_to_integer(X);
to_integer(X) when is_binary(X) -> binary_to_integer(X);
to_integer(X) when is_integer(X) -> X;
to_integer(X) -> X.

% 时间转时间戳，格式：{{2013,11,13}, {18,0,0}}
datetime_to_timestamp(DateTime) ->
	calendar:datetime_to_gregorian_seconds(DateTime) -  calendar:datetime_to_gregorian_seconds({{1970,1,1},{0,0,0}}) - 8 * 60 * 60.

% 时间戳转时间
timestamp_to_datetime(Timestamp) ->
	calendar:gregorian_seconds_to_datetime(Timestamp +  calendar:datetime_to_gregorian_seconds({{1970,1,1},{0,0,0}})).


%% 获取时间截
time() ->
	DateTime = calendar:local_time(),
	datetime_to_timestamp(DateTime).

%% 返回随机数
random() ->
	{_, _, P3} = erlang:now(),
	to_str(random:uniform(P3)).

%%　返回日期
date_str("y-m-d") ->
	{{Year, Month, Day}, {_Hour, _Min, _Sec}} = calendar:local_time(),
	to_str(Year) ++ "-" ++ to_str(Month) ++ "-" ++ to_str(Day).

date_str() ->
	{{Year, Month, Day}, {Hour, Min, Sec}} = calendar:local_time(),
	to_str(Year) ++ "-" ++ to_str(Month) ++ "-" ++ to_str(Day)
	++ " " ++ to_str(Hour) ++ ":" ++ to_str(Min) ++ ":" ++ to_str(Sec).

%% 返回目录
root_dir() ->
	replace(os:cmd("pwd"), "\n", "/").

priv_dir() ->
	replace(os:cmd("pwd"), "\n", "/priv/").

%% lib_lists
%% pmap
pmap(Fun, List) ->
	Pid = self(),
	Ref = erlang:make_ref(),
	Pids = lists:map(fun(I) ->
				spawn(fun() -> do_pmap2(Pid, Ref, Fun, I) end)
			end, List),
	gathers(Pids, Ref).

%% Fun 处理回调函数
%% L 待处理的列表
%% LimitProcess 最多使用的进程数
pmap(Fun, L, LimitProcess) ->
	NewList = heap_split(LimitProcess, L),
	Pid = self(),
	Ref = erlang:make_ref(),
	Pids = lists:map(fun(HeapList) ->
				spawn(fun() -> do_pmap3(Pid, Ref, Fun, HeapList) end)
			end, NewList),
	lists:flatten(gathers(Pids, Ref)).

do_pmap2(Parent, Ref, Fun, I) ->
	Parent ! {self(), Ref, (catch(Fun(I)))}.

do_pmap3(Parent, Ref, Fun, HeapList) ->
	ResultList = lists:map(fun(I)->
			catch(Fun(I))
		end, HeapList),
	Parent ! {self(), Ref, ResultList}.

gathers([Pid|T], Ref) ->
	receive
		{Pid, Ref, Ret}->
			[Ret|gathers(T, Ref)]
	end;
gathers([], _) ->
	[].

%%
%%将 List 分成 N 个子 List
heap_split(N, List) ->
	Length = length(List),
	{ok,{{a,A,AR},{b,_B,BR},{v,_V}}} = heap(Length, N),
	AListLength = A * AR,
	%%BListLength = B * BR,
	{AList, BList} = lists:split(AListLength, List),
	SubAList = split(AR, AList),
	SubBList = split(BR, BList),
	SubAList ++ SubBList.

heap(A, N) ->
	case A >= N of
		true ->
			R = round(A / N),
			B = (1 + R) * N - A,
			C = A - N * R,

			AA = N*R -A,
			BB = (1-R) * N  + A,

			case ((B >=0) and (B =< N) and (C >=0) and (C =< N)) of
				true ->
					List = {ok, {{a, B, R}, {b, C, R+1}, {v, R}}};
				_ ->
					case ((AA>=0) and (AA =< N) and (BB>=0) and (BB=<N)) of
						true ->
							List = {ok, {{a, AA, R-1},{b, BB, R}, {v, R}}};
						_ ->
							%% default 以防万一
							List = {ok, {{a, 0, R-1},{b, N, R}, {v, R}}}
					end
			end;
		_ ->
			List = {ok, {{a, 0, 1},{b, A, 1}, {v, 1}}}
	end,
	List.

%% N 堆大小
%% List 为要分配的列表
split(N, List) ->
	split(N, List, []).

%% N 堆大小
%% List 为要分配的列表
split(_N, [], LRes) -> lists:reverse(LRes);
split(N, List, LRes) ->
	Length = length(List),
	case Length > N of
		true ->
			{List1, List2} = lists:split(N, List),
			split(N, List2, [List1|LRes]);
		_ ->
			split(N, [], [List|LRes])
	end.

%% lib_string
%%-compile(export_all).
%% http://sen228.blog.163.com/blog/static/1648623192012112113246157/

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

%% lib_sys
% log(Str) ->
% 	Dir = root_dir() ++ "log/" ++ date_str("y-m-d") ++ "-log.txt",
% 	Log = " \n =====================" ++ date_str() ++ "============================ \n " ++ Str,
% 	append(Dir, Log).


%% 写系统日志到文件中
% write_log(Report) ->
%   Dir = root_dir() ++ "log/cache_"++ random() ++".txt",
%   {ok, S} = file:open(Dir, write),
%   io:format(S, "~p~n", [Report]),
%   file:close(S),
%   {ok, Str} = file_get_contents(Dir),
%   log(Str),
%   file:delete(Dir),
%   ok.


