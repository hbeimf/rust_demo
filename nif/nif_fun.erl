% nif_fun.erl
-module(nif_fun).
-export([load/0, test_so_func/2, hello/0]).
 
load() ->
        erlang:load_nif("./nif_fun", 0).
 
hello() ->
      "NIF library not loaded".

test_so_func(_A, _B) ->
        io:format("this function is not defined!~n").