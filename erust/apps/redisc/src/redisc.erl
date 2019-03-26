-module(redisc).
-compile(export_all).

-include("log.hrl").

-define(LOG2(X), io:format("~n==========log2========{~p,~p}==============~n~p~n", [?MODULE,?LINE,X])).


test() -> 
  ?LOG2({test_update, "v0.1.2"}),
	set(),
	redisc_get().

redisc_get() ->
    redisc_get("foo").
redisc_get(Key) ->
    redisc_call:q(pool_redis, ["GET", Key]).

set() ->
    set("foo", "bar").
set(Key, Val) ->
    redisc_call:q(pool_redis, ["SET", Key, Val]).

get() ->
    redisc:get("foo").
get(Key) ->
    redisc_call:q(pool_redis, ["GET", Key]).
    
hget() -> 
    Hash = "info@341659",
    A = hget(Hash, "gold"),
    B = hgetall(Hash),
    {A, B}.

hget(Hash, Key) -> 
    q(["hget", Hash, Key], 3000).

hgetall(Hash) -> 
    redisc_call:q(pool_redis, ["hgetall", Hash]).
    
hset(Hash, Key, Val) ->
    q(["hset", Hash, Key, Val], 3000). 


incr() ->
  incr("test_incr").
incr(Key) ->
  q(["incr", Key]).

decr() ->
  decr("test_incr").
decr(Key) ->
  q(["decr", Key]).


exists(Key) ->
  q(["exists", Key]).

del(Key) ->
  q(["del", Key]).


q(Command) -> 
    redisc_call:q(pool_redis, Command).
q(Command, Timeout) -> 
    redisc_call:q(pool_redis, Command, Timeout).

  rpush(Key, Val)->
   q(["rpush", Key, Val]).

  hincrby(Key, Mkey, Val)->
  q(["hincrby", Key, Mkey, Val]).

