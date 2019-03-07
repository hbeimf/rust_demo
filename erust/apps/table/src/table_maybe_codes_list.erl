% table_maybe_codes_list.erl

-module(table_maybe_codes_list).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").
%% 定义记录结构
-include_lib("table/include/table.hrl").

-define(TABLE, maybe_codes).

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

select(Code) ->
    do(qlc:q([X || X <- mnesia:table(?TABLE),
                X#?TABLE.code =:= Code
            ])).

% get_client(Client, gateway_id) ->
%       Client#?TABLE.gateway_id;
get_client(Client, per) ->
      Client#?TABLE.per;
get_client(Client, code) ->
      Client#?TABLE.code.



%% == 数据操作 ===============================================

%% 增加一行
% add(_UserId, undefined, undefined, undefined) ->
%     ok;
add(Code, Per) ->
    Row = #?TABLE{
        code = Code, 
        per = Per
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
new_client(Client, per, Val) ->
      Client#?TABLE{per = Val};
new_client(Client, code, Val) ->
      Client#?TABLE{code = Val};
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



