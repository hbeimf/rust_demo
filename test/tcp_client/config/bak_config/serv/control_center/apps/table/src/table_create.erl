-module(table_create).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").
%% 定义记录结构

-include("table.hrl").

%% 初始化mnesia表结构
init() ->
    	case mnesia:create_schema([node()]) of
    		ok -> 
			    mnesia:start(),
			    % mnesia:create_table(client_list, [{type, bag}, {attributes,record_info(fields,client_list)}]),
			    mnesia:create_table(gateway_list, [{attributes,record_info(fields,gateway_list)}]),
			    mnesia:create_table(game_server_list, [{attributes,record_info(fields,game_server_list)}]),
			    mnesia:create_table(client_list, [{attributes,record_info(fields,client_list)}]),
			    mnesia:create_table(client_counter, [{attributes,record_info(fields,client_counter)}]),
			    mnesia:create_table(forbidden_ip, [{attributes,record_info(fields,forbidden_ip)}]),
			    ok;
		  _ -> 
		  	mnesia:start()
	 end.



% mnesia:create_table(erlang_sequence, [{attributes, record_info(fields, erlang_sequence)} , {type,set}, {disc_copies, [node()]} ]),
