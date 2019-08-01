% demo.erl
-module(demo).
-compile(export_all).

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.


hello() ->
	io:format("hello~n"),
	ok.

-ifdef(TEST).
hello_test() ->
	io:format("hello test~n"),
	?assert(okk == hello()).
-endif.