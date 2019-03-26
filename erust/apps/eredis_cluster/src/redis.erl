-module(redis).
-compile(export_all).

% -export([test/0]).

test() -> 
	eredis_cluster:q(["GET","foo"]).



















