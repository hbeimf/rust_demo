-define(TWEPOCH, 1508980320000). %% 2017-10-26 01:12:00 (UTC)
-define(DEFAULT_WORKER_MIN_MAX, [0, 9]).

-define(LOG(X), io:format("~n==========log begin========{~p,~p}==============~n~p~n~n", [?MODULE,?LINE,X])).
% -define(LOG(X), true).
