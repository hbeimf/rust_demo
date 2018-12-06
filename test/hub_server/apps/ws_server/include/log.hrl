% -define(LOG(X), io:format("~n==========log========{~p,~p}==============~n~p~n", [?MODULE,?LINE,X])).
-define(LOG(X), true).

-define(LOG1(X), io:format("~n==========log1========{~p,~p}==============~n~p~n", [?MODULE,?LINE,X])).
% -define(LOG(X), true).

% -record(state, { 
% 	uid=0,
% 	islogin = false,
% 	stype =0,
% 	sid=0,
% 	data
% 	}).


-record(state_gateway, { 
	gateway_id=0,
	data
	}).

-record(state_game_server, { 
	server_type=0,
	server_id=0,
	data
	}).