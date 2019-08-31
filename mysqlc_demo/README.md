mysqlc_demo
=====

An OTP application

Build
-----

    $ rebar3 compile

https://blog.csdn.net/educast/article/details/23054039


erlang:system_info(process_limit).

使用cowboy_req:compact降低内存占用

init(_Any, Req, State) -> NowCount = count_server:welcome(),
io:format("online user ~p :))~n", [NowCount]),
output_first(Req),
Req2 = cowboy_req:compact(Req),
{loop, Req2, State, hibernate}.
