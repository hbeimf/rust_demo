-module(try1).
-compile(export_all).







% try1:test().
test() ->
	try
		add(1)
	catch 
		K:Error_msg->
			glib:write_req({?MODULE, ?LINE, {K, Error_msg, erlang:get_stacktrace()}}, "try1"),
			ok
	end.

add(add)->
	ok.
