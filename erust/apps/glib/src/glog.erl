% glog.erl
-module(glog).
-compile(export_all).
-include_lib("eunit/include/eunit.hrl").
-include_lib("glib/include/log.hrl").

test() ->
	{ok, Log} = log:open("log_test"),
	% {ok, {A, _}} = util:count(fun (I, _) -> log:write(Log, util:bin(I)) end, {ok, undefined}, 1000),
	W = log:write(Log, term_to_binary({hello})),
	R = log:since(Log, undefined),
	?LOG(W),
	?LOG(R),

	{ok, {Start, _}} = W,
	{_, {ok, Bin}} = log:fetch(Log, Start),
	?LOG(binary_to_term(Bin)),

	Acc = log:foldl(Log, fun(Node, Reply) -> 
		?LOG(Node),
		Reply
	end, []),
	?LOG(Acc),

	ok.

