-module(table_game_server_list).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").
%% 定义记录结构
-include_lib("table/include/table.hrl").

-define(TABLE, game_server_list).

test() -> 
	ok.

%%== 查询 =====================================

do(Q) ->
    F = fun() -> qlc:e(Q) end,
    {atomic,Val} = mnesia:transaction(F),
    Val.

%% SELECT * FROM table
%% 选取所有列
select() ->
    do(qlc:q([X || X <- mnesia:table(?TABLE)])).

select(Sid) ->
    do(qlc:q([X || X <- mnesia:table(?TABLE),
                X#?TABLE.server_id =:= Sid
            ])).


select(<<>>, <<>>) ->
  select();
select(ServerId, <<>>) ->
  select(ServerId);
select(<<>>, ServerType) ->
  do(qlc:q([X || X <- mnesia:table(?TABLE),
                X#?TABLE.server_type =:= ServerType
            ])).

get_client(Client, server_id) ->
      Client#?TABLE.server_id;
get_client(Client, server_type) ->
      Client#?TABLE.server_type;
get_client(Client, server_uri) ->
      Client#?TABLE.server_uri;
get_client(Client, gwc_uri) ->
      Client#?TABLE.gwc_uri;  
get_client(Client, max) ->
      Client#?TABLE.max;
get_client(Client, pid_to_gs) ->
      Client#?TABLE.pid_to_gs.




%% == 数据操作 ===============================================





%% 增加一行
% add(_UserId, undefined, undefined, undefined) ->
%     ok;
add(ServerId, ServerType, ServerUri, GwcUri, Max) ->
    Row = #?TABLE{
        server_id = ServerId, 
        server_type = ServerType, 
        server_uri = ServerUri, 
        gwc_uri = GwcUri,
        max = Max,
        pid_to_gs = 0
    },

    F = fun() ->
            mnesia:write(Row)
    end,
    mnesia:transaction(F).

% table_client_list:update(1, scene_id, 11).
update(Uid, Key, Val) ->
    case select(Uid) of
        [] ->
            ok;
        [Client|_] -> 
            % Row = Client#?TABLE{scene_id = SceneId},
            Row = new_client(Client, Key, Val),
            update_row(Row)
    end.


% -record(game_server_list, {
% 	server_id=0, %%  游戏服id
% 	server_type=0, %%  游戏服类型
% 	server_uri="",  %%  游戏服地址
% 	max=0 %%   游戏服最多能容纳多少链接 
	
% }).


% new_client(Client, userid, UserId) ->
%      Client#?TABLE{userid = UserId};
new_client(Client, server_id, Val) ->
      Client#?TABLE{server_id = Val};
new_client(Client, server_type, Val) ->
      Client#?TABLE{server_type = Val};
new_client(Client, server_uri, Val) ->
      Client#?TABLE{server_uri = Val};
new_client(Client, gwc_uri, Val) ->
      Client#?TABLE{gwc_uri = Val};
new_client(Client, max, Val) ->
      Client#?TABLE{max = Val};
new_client(Client, pid_to_gs, Val) ->
      Client#?TABLE{pid_to_gs = Val};
new_client(Client, _, _) ->
      Client.

update_row(Row) -> 
    F = fun() ->
            mnesia:write(Row)
    end,
    mnesia:transaction(F).

%% 删除一行
delete(Uid) ->
    Oid = {?TABLE, Uid},
    F = fun() ->
            mnesia:delete(Oid)
    end,
    mnesia:transaction(F).

count() -> 
    F = fun() ->  
        mnesia:table_info(?TABLE, size)  
    end,  
    case mnesia:transaction(F) of
        {atomic,Size} ->
            Size;
        _ -> 
            0
    end. 



