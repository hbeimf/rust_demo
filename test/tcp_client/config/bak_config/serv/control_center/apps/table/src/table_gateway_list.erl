-module(table_gateway_list).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").
%% 定义记录结构
-include_lib("table/include/table.hrl").

-define(TABLE, gateway_list).

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
                X#?TABLE.gateway_id =:= Uid
            ])).

get_client(Client, gateway_id) ->
      Client#?TABLE.gateway_id;
get_client(Client, gateway_uri) ->
      Client#?TABLE.gateway_uri;
get_client(Client, pid) ->
      Client#?TABLE.pid.



%% == 数据操作 ===============================================

%% 增加一行
% add(_UserId, undefined, undefined, undefined) ->
%     ok;
add(GatewayId, GatewayUri, Pid) ->
    Row = #?TABLE{
        gateway_id = GatewayId, 
        gateway_uri = GatewayUri, 
        pid = Pid
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


% -record(gateway_list, {
%     gateway_id=0, %%  网关id
%     gateway_uri="", %%   网关 ws地址
%     pid=0 %%  
% }).

% new_client(Client, userid, UserId) ->
%      Client#?TABLE{userid = UserId};
new_client(Client, gateway_id, Val) ->
      Client#?TABLE{gateway_id = Val};
new_client(Client, gateway_uri, Val) ->
      Client#?TABLE{gateway_uri = Val};
new_client(Client, pid, Val) ->
      Client#?TABLE{pid = Val};
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



