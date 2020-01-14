%%%-------------------------------------------------------------------
%%% @author mm
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. Jan 2020 10:11 AM
%%%-------------------------------------------------------------------
-module(table_pools).
-author("mm").

-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").
%% 定义记录结构
-include_lib("table/include/table.hrl").

-define(TABLE, pools).

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
  Node = sys_config:get_config(node, node_id),
  do(qlc:q([X || X <- mnesia:table(?TABLE),
    X#?TABLE.pool_group =:= Key
    , X#?TABLE.node =:= Node  
  ])).

%%-record(cluster, {
%%  cluster_id,
%%  node_id,
%%  size,
%%  work_id
%%}).


% count_all() ->
%     Rows = select(),
%     lists:foldl(fun(Row, Res)  ->
%         case table_client_counter:get_client(Row, key) of
%                     {server_id, ServerId} ->
%                         Num = table_client_counter:get_client(Row, counter),
%                         ServerType = table_game_server_list:select_servertype_by_sid(ServerId),
%                         case ServerType of
%                             <<>> ->
%                                 Res;
%                             _ ->
%                                  [{ServerType, ServerId, Num}|Res]
%                         end;
%                     _ ->
%                         Res
%         end
%     end, [], Rows).


% % table_client_counter:counter_list(ServerType, ServerId).
% % table_client_counter:counter_list(<<>>, <<>>).
% counter_list(<<>>, <<>>) ->
%     count_all();
% counter_list(ServerType, <<>>) ->
%     Rows = count_all(),
%     lists:foldl(fun({ServerType1, ServerId, Num} = Row, Res) ->
%             case ServerType1 of
%                 ServerType ->
%                     [Row|Res];
%                 _ ->
%                     Res
%             end
%     end, [], Rows);
% counter_list(<<>>, ServerId) ->
%    Rows = count_all(),
%     lists:foldl(fun({ServerType1, ServerId1, Num} = Row, Res) ->
%             case ServerId1 of
%                 ServerId ->
%                     [Row|Res];
%                 _ ->
%                     Res
%             end
%     end, [], Rows);
% counter_list(ServerType, ServerId) ->
%     Rows = count_all(),
%     lists:foldl(fun({ServerType1, ServerId1, Num} = Row, Res) ->
%             case {ServerType1, ServerId1} of
%                 {ServerType, ServerId} ->
%                     [Row|Res];
%                 _ ->
%                     Res
%             end
%     end, [], Rows).

% % table_client_counter:select_counter(ServerType, ServerId).
% select_counter(<<>>, <<>>) ->
%     table_client_list:count();
% select_counter(ServerType, <<>>) ->
%     Counter = select({server_type, ServerType}),
%     get_counter(Counter);
% select_counter(<<>>, ServerId) ->
%     Counter = select({server_id, ServerId}),
%     get_counter(Counter);
% select_counter(ServerType, ServerId) ->
%     Counter = select({ServerType, ServerId}),
%     get_counter(Counter).
% % select_counter(_, _) ->
% %     table_client_list:count().


% get_counter([]) ->
%     0;
% get_counter([Counter|_]) ->
%     get_client(Counter, counter).


%%-record(cluster, {
%%  cluster_id,
%%  node_id,
%%  size,
%%  work_id
%%}).

get_client(Client, pool_id) ->
  Client#?TABLE.pool_id;
get_client(Client, pool_size) ->
  Client#?TABLE.pool_size;
get_client(Client, pid) ->
  Client#?TABLE.pid;
get_client(Client, pool_group) ->
  Client#?TABLE.pool_group.



%% == 数据操作 ===============================================

%% 增加一行
% add(_UserId, undefined, undefined, undefined) ->
%     ok;

% % table_client_counter:incr({1,2}).
% incr(Key) ->
% 	incr(Key, 1).
% incr(Key, Val) ->
% 	NewVal = mnesia:dirty_update_counter(?TABLE, Key, Val),
% 	NewVal.

% decr(Key) ->
% 	decr(Key, -1).
% decr(Key, Val) ->
% 	NewVal = mnesia:dirty_update_counter(?TABLE, Key, Val),
% 	NewVal.


%%-record(cluster, {
%%  cluster_id,
%%  node_id,
%%  size,
%%  work_id
%%}).

add(PoolId, PoolSize, Pid, PoolGroup) ->
  Node = sys_config:get_config(node, node_id),
  Row = #?TABLE{
    pool_id = PoolId,
    pool_size = PoolSize,
    pid = Pid,
    pool_group = PoolGroup,
    node = Node
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

%%
%%-record(cluster, {
%%  cluster_id,
%%  node_id,
%%  size,
%%  work_id,
%%  work_pid
%%}).


% new_client(Client, userid, UserId) ->
%      Client#?TABLE{userid = UserId};
new_client(Client, pool_id, Val) ->
  Client#?TABLE{pool_id = Val};
new_client(Client, pool_size, Val) ->
  Client#?TABLE{pool_size = Val};
new_client(Client, pid, Val) ->
  Client#?TABLE{pid = Val};
new_client(Client, pool_group, Val) ->
  Client#?TABLE{pool_group = Val};
new_client(Client, node, Val) ->
  Client#?TABLE{node = Val};
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



