-module(niftest).

-export([init/0, hello/0]).

init() ->

      erlang:load_nif("./niftest", 0).

hello() ->

      "NIF library not loaded".


% 1> c(niftest).

% {ok,niftest}

% 2> niftest:hello().

% "NIF library not loaded"

% 3> niftest:init().

% ok

% 4> niftest:hello().

% "Hello world!"