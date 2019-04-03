% glog.erl
-module(glog).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").
-include_lib("glib/include/log.hrl").

test() ->
	Dir = "log_test",
	W = write(Dir, {hello}),
	LogPid = log_pid(Dir),
	R = log:since(LogPid, undefined),
	?LOG(W),
	?LOG(R),

	{ok, {Start, _}} = W,
	{_, {ok, Bin}} = log:fetch(LogPid, Start),
	?LOG(binary_to_term(Bin)),

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
	Pid = glib_sup:start_log(Dir),
	log:write(Pid, term_to_binary(TermLog)).





