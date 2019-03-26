-module(redis).
-compile(export_all).

-define(LOG2(X), io:format("~n==========log2========{~p,~p}==============~n~p~n", [?MODULE,?LINE,X])).


test() -> 
  ?LOG2({test_update, "v0.1.2"}),
	set(),
	redisc_get().

redisc_get() ->
    redisc_get("foo").
redisc_get(Key) ->
    q(["GET", Key]).

set() ->
    set("foo", "bar").
set(Key, Val) ->
    q(["SET", Key, Val]).

get() ->
    redis:get("foo").
get(Key) ->
    q(["GET", Key]).
    
hget() -> 
    Hash = "info@341659",
    A = hget(Hash, "gold"),
    B = hgetall(Hash),
    {A, B}.

hget(Hash, Key) -> 
    q(["hget", Hash, Key]).

hgetall(Hash) -> 
    q(["hgetall", Hash]).
    
hset(Hash, Key, Val) ->
    q(["hset", Hash, Key, Val]). 

incr() ->
  incr("test_incr").
incr(Key) ->
  q(["incr", Key]).

decr() ->
  decr("test_incr").
decr(Key) ->
  q(["decr", Key]).



q(Command) -> 
    eredis_cluster:q(Command).















