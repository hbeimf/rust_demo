-module(glib).
-compile(export_all).

% -export([package/2, unpackage/1, test/0]).

-define( UINT, 32/unsigned-little-integer).
% -define( INT, 32/signed-little-integer).
-define( USHORT, 16/unsigned-little-integer).
% -define( SHORT, 16/signed-little-integer).
% -define( UBYTE, 8/unsigned-little-integer).
% -define( BYTE, 8/signed-little-integer).
-include_lib("glib/include/log.hrl").
-include_lib("glib/include/gwc_proto.hrl").

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

parse_body(PackageLen, _ ) when PackageLen > 307200 ->
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
	T = glib:time(),
	{{Y, Mon, D}, {H, M, S}} = timestamp_to_datetime(T),
	lists:concat([Y, "-", Mon, "-" , D, " ", H, ":", M, ":", S]).
get_date2()->
	T = glib:time(),
	{{Y, Mon, D}, {H, M, S}} = timestamp_to_datetime(T),
	lists:concat([Y,  Mon, D, H, M, S]).

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
	case is_dir(Dir) of 
		false ->
    		file:make_dir(Dir);
    	_ ->
    		ok
   	end.

del_dir(Dir) ->
    file:del_dir(Dir).

% 写系统日志到文件中
write_req(Report, Api) -> 
	IsDebug = sys_config:is_debug(),
	write_req(Report, Api, IsDebug).

write_req(Report, Api, true) ->
	make_dir(root_dir() ++ "log"),
	Dir = root_dir() ++ "log/cache_"++ random() ++".txt",
	{ok, S} = file:open(Dir, write),
	io:format(S, "~p~n", [Report]),
	file:close(S),
	{ok, Str} = file_get_contents(Dir),
	req_log(Str, Api),
	file:delete(Dir),
	ok;
write_req(_Report, _Api, _) -> 
	ok.

req_log(Str, Api) ->
	Dir = root_dir() ++ "log/" ++ date_str("y-m-d") ++ "-"++ to_str(Api) ++"-log.txt",
	Log = " \n =====================" ++ date_str() ++ "============================ \n " ++ Str,	
	%% 同时写入文件
	append(Dir, Log).

% 写系统日志到文件中
write_log(Report) ->
	IsDebug = sys_config:is_debug(),
	write_log(Report, IsDebug).

write_log(Report, true) ->
	make_dir(root_dir() ++ "log"),
	Dir = root_dir() ++ "log/cache_"++ random() ++".txt",
	{ok, S} = file:open(Dir, write),
	io:format(S, "~p~n", [Report]),
	file:close(S),
	{ok, Str} = file_get_contents(Dir),
	log(Str),
	file:delete(Dir),
	ok;
write_log(_, _) -> 
	ok.

log(Str) ->
	Dir = root_dir() ++ "log/" ++ date_str("y-m-d") ++ "-log.txt",
	Log = " \n =====================" ++ date_str() ++ "============================ \n " ++ Str,
	
	%% 同时写入文件
	append(Dir, Log),

	%% 写入错误队列
	rabbit_error_log_send:send(to_binary(Log)).


%% 返回随机数
random() ->
	% {_, _, P3} = erlang:now(),
	% to_str(random:uniform(P3)).
	to_str(uid()).

%%　返回日期
date_str("Ym")->
	{{Year, Month, _Day}, {_Hour, _Min, _Sec}} = calendar:local_time(),
	to_str(Year) ++ to_str(month(Month)) ;
date_str("y-m-d") ->
	{{Year, Month, Day}, {_Hour, _Min, _Sec}} = calendar:local_time(),
	to_str(Year) ++ "-" ++ to_str(Month) ++ "-" ++ to_str(Day).

date_str() ->
	{{Year, Month, Day}, {Hour, Min, Sec}} = calendar:local_time(),
	to_str(Year) ++ "-" ++ to_str(month(Month)) ++ "-" ++ to_str(Day)
	++ " " ++ to_str(month(Hour)) ++ ":" ++ to_str(month(Min)) ++ ":" ++ to_str(month(Sec)) ++ "."
	 ++ to_str(micro_sec()).



month(Month) when Month < 10 ->
	lists:concat(["0", Month]);
month(Month) ->
	Month.

micro_sec() -> 
	{_, _, MicroSec} = os:timestamp(),
	Micro = string:left(to_str(MicroSec),3),
	% 毫秒必须是3位，不足3位补0
	add_zero(Micro, 3).

micro_time()->
	{F, S, MicroSec} = os:timestamp(),
	Micro = string:left(to_str(MicroSec),3),
	lists:concat([F, S, Micro]).

add_zero(Str, MustLen) ->
	StrLen = erlang:length(Str),
	case StrLen >= MustLen of 
		true -> 
			Str;
		_ -> 
			NeedAdd = MustLen - StrLen,
			Zero = lists:concat(lists:duplicate(NeedAdd,"0")),
			Zero ++ Str
	end.

% =====================================

get_ip() -> 
	{ok, L} = inet:getif(),
	lists:foldl(fun({Ip, _, _}, Reply) -> 
		[Ip|Reply]
	end, [], L).

get_ip_str() ->
	IpList = get_ip(),
	get_ip_str(IpList).

get_ip_str([]) ->
	ok;
get_ip_str(Ips) ->
	R = lists:map(fun({P1, P2, P3, P4}) -> 
		lists:concat([P1, ".", P2,".", P3, ".",P4])
	end, Ips),
	implode(R, "||").

% glib:get_ip_from_node().
get_ip_from_node() ->
	Node = to_str(node()),
	List = explode(Node, "@"),
	lists:last(List).
	% ok.


% cors
header_list() ->
	[
		{<<"content-type">>, <<"text/javascript; charset=utf-8">>}
		,{<<"Access-Control-Allow-Origin">>, <<"*">>}
		,{<<"Access-Control-Allow-Headers">>, <<"X-Requested-With">>}
		,{<<"Access-Control-Allow-Methods">>, <<"GET,POST">>}
		,{<<"connection">>, <<"close">>}

	].

% glib:report_2_gwc().
report_2_gwc() ->
	ReportUri = report_uri(),
	%?LOG(ReportUri),
	_Reply = glib:http_get(ReportUri),
	%?LOG(Reply),
	ok.	

report_uri() ->
	ReportServerInfo = report_server_info(),
	{ok, ConfigList} = sys_config:get_config(gateway_control_param),
	Server = get_by_key(server,ConfigList),
	lists:concat([glib:to_str(Server), "/report?ReportServerInfo=", glib:to_str(ReportServerInfo)]).

% glib_pb:report_server_info().
report_server_info() ->
	{ok, ConfigList} = sys_config:get_config(report_param),
	ServerType = get_by_key(server_type,ConfigList),
	ServerID = get_by_key(server_id,ConfigList),
	ServerURI = get_by_key(server_logic_uri,ConfigList),
	GwcURI = get_by_key(server_control_uri,ConfigList),
	Max = get_by_key(max,ConfigList),

	%?LOG({ServerType, ServerID, ServerURI, GwcURI, Max}),

	ReportServerInfo = #'ReportServerInfo'{serverType = ServerType, 
			serverID = ServerID, 
			serverURI= ServerURI,
			gwcURI = GwcURI,
			max = glib:to_integer(Max)},
	Pb = gwc_proto:encode_msg(ReportServerInfo),
	base64:encode(Pb).



get_by_key(Key, TupleList) ->
	get_by_key(Key, TupleList, <<"">>).

get_by_key(Key, TupleList, Default) ->
	case lists:keytake(Key, 1, TupleList) of 
		{_, {_, undefined}, _} ->
			Default;
		{_, {_, Val}, _} ->
			Val;
		_ ->
			Default
	end.

gold_to_binary(Num)->
	Num1= to_str(Num),
	[Gold|_] = explode(Num1, "."),
	to_integer(Gold).

% 用在rebar3发布的配置文件中
apps() ->
    Apps = application:which_applications(),

    AppList = lists:foldl(fun({App, _, _}, ReleaseAppList) ->
        [App|ReleaseAppList]
    end, [], Apps),

    io:format("~n~p~n~n", [AppList]),
    ok.

list_length([]) ->
  0;
list_length([_ | Rest]) ->
  1 + list_length(Rest).


ceil(N) ->
     T = trunc(N),
     case N == T of
         true  -> T;
         false -> 1 + T
     end.
     
isset([], _)->
	false;
isset(List, Key)->
	case get_by_key(Key,List, "") of
		""->
			false;
		_->
			true
	end.


isset_recursion([],Keys, Bool)->
	case Keys of
		[]->
			Bool;
		_->
			false
	end;
isset_recursion(_, [], Bool)->
	Bool;
isset_recursion (Arr, [K|Key_list], _Bool)->
	case isset(Arr, K) of
		true->
			Val = get_by_key(K, Arr),
			isset_recursion(Val, Key_list, true);
		_->
			isset_recursion([], [], false)
	end.


% (cannon_fishing_master@127.0.0.1)2> glib:to_num("0.3").
% 0.3
% (cannon_fishing_master@127.0.0.1)3> glib:to_num("3").  
% 3
to_num(Str) ->
	P = string:chr(Str, $.),
	case P > 0 of 
		true ->
			list_to_float(Str);
		_ -> 
			to_integer(Str)
	end.

array_merge(Arr, {K,V})->
	[{K,V} | [{X, Y}||{X, Y}<-Arr, K=/=X]];
array_merge(Arr, [{K,V}])->
	[{K,V} | [{X, Y}||{X, Y}<-Arr, K=/=X]].



%替换数组
% List = [{a, [{b, [{c, ttt}]}]}].
% glib:array_merge_recursion(List, [a,b,c], ddd).
array_merge_recursion(_, [], New_val)->
	New_val;
array_merge_recursion(Arr, [Key|Keys], New_val)->
	Val = glib:get_by_key(Key, Arr, ""),
	case Val of
		""->
			Tmp = lists:foldr(fun(K, V) -> [{K, V}] end, New_val,  Keys),
			[{Key, Tmp}|Arr];

		_->
			Tmp = array_merge_recursion(Val, Keys, New_val),
			Arr1 = [{K, V} || {K, V}<-Arr, K=/=Key],
			[{Key, Tmp}|Arr1]
	end.

	
get_by_key_recursion(Arr, [])->
	Arr;
get_by_key_recursion(Arr, [Key|Tail])->
	New_Arr = get_by_key(Key, Arr),
	get_by_key_recursion(New_Arr, Tail).


get_rand(Size)->
	Tmp = os:timestamp(),
	Tmp rem Size.

list_get_by_index([], Index, Inc, Length, {Find_item, List_after_pop})->
	{Find_item, List_after_pop};
list_get_by_index([Item|Tail], Index, Inc, Length, {Find_item, List_after_pop})->
	case Index == Inc of
		true->
			list_get_by_index([], Index, Inc, Length, {Item, List_after_pop});
		_->
			case Inc>=Length of
				true->
					list_get_by_index([], Index, Inc, Length, {Find_item, [Item | List_after_pop]}); %break
				_->
					Inc1 = Inc+1,
					list_get_by_index(Tail, Index, Inc1, Length, {Find_item, [Item | List_after_pop]})
			end
	end.