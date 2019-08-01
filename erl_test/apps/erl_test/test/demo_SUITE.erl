-module(demo_SUITE).
-compile(export_all).


% -include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").

all() ->
	[test1, test2].

test1(_) ->
	io:format("test... ~n"),
	ok.

test2(_) ->
	% io:format("hello test~n"),
	Reply = demo:hello(),
	% io:format("reply: ~p~n", [Reply]),
	?assert(ok == Reply),
	% io:format("test... ~n"),
	false.

