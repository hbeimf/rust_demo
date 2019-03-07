% ll.erl

% -define(LOG(X), io:format("~n==========log========{~p,~p}==============~n~p~n", [?MODULE,?LINE,X])).

-module(ll).
-compile(export_all).

% ll:print().
print() -> 
	Data = table_maybe_codes_list:select(),
	print(Data).


print([]) ->
	ok;
print([Data|Tail]) ->  
	Code = table_maybe_codes_list:get_client(Data, code),
	Per = table_maybe_codes_list:get_client(Data, per),
	io:format("{code: ~p},{per: ~p} ~n", [Code, Per]),
	print(Tail).


