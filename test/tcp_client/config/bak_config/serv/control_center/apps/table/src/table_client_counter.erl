-module(table_client_counter).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").
%% 定义记录结构
-include_lib("table/include/table.hrl").

-define(TABLE, client_counter).

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

select(Key) ->
    do(qlc:q([X || X <- mnesia:table(?TABLE),
                X#?TABLE.key =:= Key
            ])).


% table_client_counter:select_counter(ServerType, ServerId).
select_counter(<<>>, <<>>) ->
    table_client_list:count();
select_counter(ServerType, <<>>) ->
    Counter = select({server_type, ServerType}),
    get_counter(Counter);
select_counter(<<>>, ServerId) ->
    Counter = select({server_id, ServerId}),
    get_counter(Counter);
select_counter(ServerType, ServerId) ->
    Counter = select({ServerType, ServerId}),
    get_counter(Counter).
% select_counter(_, _) ->
%     table_client_list:count().


get_counter([]) ->
    0;
get_counter([Counter|_]) ->
    get_client(Counter, counter).


get_client(Client, key) ->
      Client#?TABLE.key;
get_client(Client, counter) ->
      Client#?TABLE.counter.

%% == 数据操作 ===============================================

%% 增加一行
% add(_UserId, undefined, undefined, undefined) ->
%     ok;

% table_client_counter:incr({1,2}).
incr(Key) ->
	incr(Key, 1).
incr(Key, Val) ->
	NewVal = mnesia:dirty_update_counter(?TABLE, Key, Val),
	NewVal.

decr(Key) ->
	decr(Key, -1).
decr(Key, Val) ->
	NewVal = mnesia:dirty_update_counter(?TABLE, Key, Val),
	NewVal.
	
add(Key, Counter) ->
    Row = #?TABLE{
        key = Key, 
        counter = Counter
    },

    F = fun() ->
            mnesia:write(Row)
    end,
    mnesia:transaction(F).





% table_client_list:update(1, scene_id, 11).
update(TableKey, FieldKey, Val) ->
    case select(TableKey) of
        [] ->
            ok;
        [Client|_] -> 
            % Row = Client#?TABLE{scene_id = SceneId},
            Row = new_client(Client, FieldKey, Val),
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
new_client(Client, key, Val) ->
      Client#?TABLE{key = Val};
new_client(Client, counter, Val) ->
      Client#?TABLE{counter = Val};
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



