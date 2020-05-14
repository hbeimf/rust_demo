% nif_fun.erl
-module(fc).
-export([load/0, add/2, hello/0]).
 
load() ->
        erlang:load_nif("./fc", 0).
 
hello() ->
      "NIF library not loaded".

add(_A, _B) ->
        io:format("this function is not defined!~n").

%  maomao@maomao-VirtualBox:/erlang/rust_demo/nif$ erl
% Erlang/OTP 18 [erts-7.3] [source] [64-bit] [smp:2:2] [async-threads:10] [hipe] [kernel-poll:false]

% Eshell V7.3  (abort with ^G)
% 1> c(nif_fun).
% {ok,nif_fun}
% 2> nif_fun:load().
% ok
% 3> nif_fun:hello().
% "Hello world!"
% 4> nif_fun:add(2,5).
