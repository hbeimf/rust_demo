% redisc.erl
-module(redisc).
-compile(export_all).

test() -> 
	eredis_cluster:q(["GET","abc"]).