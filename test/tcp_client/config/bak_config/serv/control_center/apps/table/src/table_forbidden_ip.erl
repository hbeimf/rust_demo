% table_forbidden_ip.erl
-module(table_forbidden_ip).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").
%% 定义记录结构
-include_lib("table/include/table.hrl").

-define(TABLE, forbidden_ip).

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

select(Ip) ->
    do(qlc:q([X || X <- mnesia:table(?TABLE),
                X#?TABLE.name =:= Ip
            ])).

% get_client(Client, gateway_id) ->
%       Client#?TABLE.gateway_id;
get_client(Client, name) ->
      Client#?TABLE.name;
get_client(Client, ip) ->
      Client#?TABLE.ip.



%% == 数据操作 ===============================================

%% 增加一行
% add(_UserId, undefined, undefined, undefined) ->
%     ok;
add(Ip) ->
    Row = #?TABLE{
        % gateway_id = GatewayId, 
        % gateway_uri = GatewayUri,
        name = Ip, 
        ip = Ip
    },

    F = fun() ->
            mnesia:write(Row)
    end,
    mnesia:transaction(F).

% table_client_list:update(1, scene_id, 11).
update(Ip, Key, Val) ->
    case select(Ip) of
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
% new_client(Client, gateway_id, Val) ->
%       Client#?TABLE{gateway_id = Val};
new_client(Client, name, Val) ->
      Client#?TABLE{name = Val};
new_client(Client, ip, Val) ->
      Client#?TABLE{ip = Val};
new_client(Client, _, _) ->
      Client.

update_row(Row) -> 
    F = fun() ->
            mnesia:write(Row)
    end,
    mnesia:transaction(F).

%% 删除一行
delete(Ip) ->
    Oid = {?TABLE, Ip},
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



