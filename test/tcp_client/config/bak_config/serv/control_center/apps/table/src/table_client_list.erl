-module(table_client_list).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").
%% 定义记录结构
-include_lib("table/include/table.hrl").

-define(TABLE, client_list).

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

select(Uid) ->
    do(qlc:q([X || X <- mnesia:table(?TABLE),
                X#?TABLE.uid =:= Uid
            ])).


% -record(client_list, {
%     uid=0, %%  客户端  uid
%     server_type="",
%     server_id = "",
%     gateway_id=0, %%  网关id
%     cache_bin = ""  %% 缓存二进制数据
% }).



get_client(Client, uid) ->
      Client#?TABLE.uid;
get_client(Client, server_type) ->
      Client#?TABLE.server_type;
get_client(Client, server_id) ->
      Client#?TABLE.server_id;
get_client(Client, gateway_id) ->
      Client#?TABLE.gateway_id;
get_client(Client, cache_bin) ->
      Client#?TABLE.cache_bin.

%% == 数据操作 ===============================================

%% 增加一行
% add(_UserId, undefined, undefined, undefined) ->
%     ok;


add(Uid, ServerType, ServerId, GatewayId) ->
	add(Uid, ServerType, ServerId, GatewayId, <<"">>).

add(Uid, ServerType, ServerId, GatewayId, CacheBin) ->
    Row = #?TABLE{
        uid = Uid, 
        server_type = ServerType,
        server_id = ServerId,
        gateway_id = GatewayId,
        cache_bin = CacheBin
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


% -record(client_list, {
%   uid=0, %%  客户端  uid
%   pid_front=0, %%  客户端连接代理的 pid
%   pid_backend=0,  %%  连接游戏服的 pid
%   server_type="", %%   连接游戏服type
%   server_id=0 %%  连接游戏服 id
% }).


% new_client(Client, userid, UserId) ->
%      Client#?TABLE{userid = UserId};
new_client(Client, uid, Val) ->
      Client#?TABLE{uid = Val};
new_client(Client, server_type, Val) ->
      Client#?TABLE{server_type = Val};
new_client(Client, server_id, Val) ->
      Client#?TABLE{server_id = Val};
new_client(Client, gateway_id, Val) ->
      Client#?TABLE{gateway_id = Val};
new_client(Client, cache_bin, Val) ->
      Client#?TABLE{cache_bin = Val};
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



