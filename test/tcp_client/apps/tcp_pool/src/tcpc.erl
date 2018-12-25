% tcpc.erl
-module(tcpc).
-compile(export_all).

-define(TIMEOUT, 5000).

call(Package) ->	
	poolboy:transaction(pool_name(), fun(Worker) ->
        gen_server:call(Worker, {call, Package}, ?TIMEOUT)
    end).

pool_name() ->
	pool1.