% demo_SUITE.erl
% demo.erl
-module(demo_SUITE).
-compile(export_all).

% -module(demo_SUITE).

-include_lib("common_test/include/ct.hrl").

% %% ct.
% -export([all/0]).

% %% Tests.
% -export([eunit/1]).

%% ct.

all() ->
	[eunit].

eunit(_) ->
	ok = eunit:test({application, erl_test}).


% -ifdef(TEST).
% -include_lib("eunit/include/eunit.hrl").
% -endif.


% all() ->
% 	[eunit].

% eunit(_) ->
% 	ok = eunit:test({application, cowlib}).


% all() ->
% 	[hello_test].

% hello_test() ->
% 	io:format("hello test~n"),
% 	Reply = demo:hello(),
% 	% ?assert(ok == Reply).
% 	ok.

% -ifdef(TEST).
 
% hello_test() ->
% 	io:format("hello test =========== ~n"),
% 	Reply = hello(),
% 	?assertNot(ok == Reply).

% -endif.