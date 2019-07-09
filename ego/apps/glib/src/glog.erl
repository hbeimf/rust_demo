% glog.erl
-module(glog).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").
-include_lib("glib/include/log.hrl").

% write 
tt() -> 
	lists:foreach(fun(I) -> 
		test()
	end, lists:seq(1,1000)),
	ok.

test_write() ->
	Dir = dir(),
	R = lists:foldl(fun(I, Reply) -> 
		W = write(Dir, {I, hello, world}),
		[{I, W}|Reply]
	end, [], lists:seq(1,20)),
	?LOG(R),
	ok.
	

% // read 
test_read() ->
	Dir = dir(),
	% LogPid = log_pid(Dir),
	% R = log:since(LogPid, undefined),
	% ?LOG(W),
	% ?LOG(R),

	% {ok, {Start, _}} = W,
	% {_, {ok, Bin}} = log:fetch(LogPid, Start),
	% ?LOG(binary_to_term(Bin)),

	foreach_log(Dir),
	ok.



foreach_log(Dir) ->
	LogPid = log_pid(Dir),
	Acc = log:foldl(LogPid, fun(EachLog, Reply) -> 
		{{Start, Next}, {ok, BinLog}} = EachLog,
		Log = binary_to_term(BinLog),
		?LOG([{start, Start}, {next, Next}, {log, Log}]),
		Reply
	end, []),
	?LOG(Acc),
	ok.

log_pid(Dir) ->
	glib_sup:start_log(Dir).

write(Dir, TermLog) -> 
	Pid = log_pid(Dir),
	LogTime = glib:date_str(),
	Log = {LogTime, TermLog},
	log:write(Pid, term_to_binary(Log)).


range() ->
	Dir = dir(),
	range(Dir, {<<"00/00">>,131}, {<<"00/00">>,1733}).
range(Dir, Start, End) ->
	 Pid = log_pid(Dir),	
	 log:range(Pid, {Start, End}).


limit() ->
	Dir = dir(),
	limit(Dir, {<<"00/00">>,131}, {<<"00/00">>,1733}).
limit(Dir, Start, End) ->
	Pid = log_pid(Dir),	
	Range = {Start, End},
	log:limit(Pid, fun(D, Reply) -> 
		{_, {ok, Bin}} = D,
		?LOG(binary_to_term(Bin)),
		Reply
	end, [], Range, []),
	ok.


% [{20,{ok,{{<<"00/00">>,1733},{<<"00/00">>,1822}}}},
% ...
%  {2,{ok,{{<<"00/00">>,131},{<<"00/00">>,220}}}},
%  {1,{ok,{{<<"00/00">>,42},{<<"00/00">>,131}}}}]

fetch()->
	Dir = dir(),
	{_, {ok, Bin}} = fetch(Dir, {<<"00/00">>,1733}),
	?LOG(binary_to_term(Bin)),
	ok.
fetch(Dir, Position) ->
	Pid = log_pid(Dir),	
	log:fetch(Pid, Position).


dir() -> 
	Dir = "log_test",
	Dir.	

