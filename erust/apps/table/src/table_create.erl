-module(table_create).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").
%% 定义记录结构

-include("table.hrl").
% -include_lib("ws_server/include/log.hrl").

-define(WAIT_FOR_TABLES, 10000).

%% 初始化mnesia表结构
init() ->
	case mnesia:create_schema([node()]) of
		ok -> 
			    mnesia:start(),
			    mnesia:create_table(codes, [{attributes,record_info(fields,codes)}]),
			    mnesia:create_table(maybe_codes, [{attributes,record_info(fields,maybe_codes)}]),
			    ok;
	  _ -> 
	  	mnesia:start()
	 end.



