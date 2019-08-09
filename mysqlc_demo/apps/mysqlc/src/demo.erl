% demo.erl
-module(demo).

-include_lib("glib/include/log.hrl").
-compile(export_all).


test() -> 

	select1(),
	select2(),
	select3(),

	ok.




select1() -> 
	Sql = "show tables",
	R = mysqlc_comm:select(1, Sql),
	?LOG(R),
	ok.

select2() -> 
	Sql = "show tables",
	R = mysqlc_comm:select(2, Sql),
	?LOG(R),
	ok.

select3() -> 
	Sql = "show tables",
	R = mysqlc_comm:select(3, Sql),
	?LOG(R),
	ok.

