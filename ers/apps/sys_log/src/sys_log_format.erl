% sys_log_format.erl
-module(sys_log_format).
-compile(export_all).

% -include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").



% sys_log_format:test().
test() ->
	test_format(),
	test_format_json(),
	test_format_other(),
	ok.


test_format() -> 
	Data = [
		atom_test 
		,{tuple, <<"test">>}
		,[
			{<<"user_name">>, "test"}
			, {password, 123456}
			, {<<"zh">>, unicode:characters_to_binary("异常错误 ")}
		]
	],

	% ?LOG(Data),


	% F = io_lib:format("~w", [Data]),
	F = lists:flatten(io_lib:format("~w",[Data])),
	% ?LOG(F),
	?WRITE_JSON("ww", F),

	F1 = lists:flatten(io_lib:format("~p",[Data])),
	F11 = glib:replace(F1, "\n", ""),
	% ?LOG(F1),
	% ?LOG(F11),

	?WRITE_JSON("pp", F1),
	?WRITE_JSON("ppp", F11),
	
	% F2 = lists:flatten(io_lib:format("~s",[Data])),
	% ?LOG(F2),
	
	

	ok.


test_format_json() -> 
	Data = [
	        {<<"user_name">>, unicode:characters_to_binary("小强")}
	        , {<<"password">>, <<"a123456">>}
	        , {<<"index">>, 123456}

	    ],
	Json = jsx:encode(Data),
	Format = format(Json),
	?WRITE_JSON("format_json", Format),
	ok.


test_format_other() -> 
	Data = [
	        {<<"user_name">>, unicode:characters_to_binary("小强")}
	        , {<<"password">>, <<"a123456">>}
	        , {<<"index">>, 123456}

	    ],
	% Json = jsx:encode(Data),
	Format = format(Data),
	?WRITE_JSON("format_other_erlang_ds", Format),
	ok.


format(Data) ->
	case jsx:is_json(Data) of
		true -> 
			Data;
		_ -> 
			F1 = lists:flatten(io_lib:format("~p",[Data])),
			glib:replace(F1, "\n", "")
	end.





