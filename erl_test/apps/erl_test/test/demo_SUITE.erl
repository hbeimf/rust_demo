-module(demo_SUITE).
-compile(export_all).


% -include_lib("common_test/include/ct.hrl").
-include_lib("eunit/include/eunit.hrl").

all() ->
	[test1, test_fail, test3].

test1(_) ->
	io:format("test... ~n"),
	ok.

test_fail(_) ->
	% io:format("hello test~n"),
	Reply = demo:hello(),
	% io:format("reply: ~p~n", [Reply]),
	?assert(ok == Reply),
	% io:format("test... ~n"),
	false.

test3(_) ->
	io:format("test... ~n"),
	ok.

eunit(_) ->
	ok = eunit:test({application, erl_test}).