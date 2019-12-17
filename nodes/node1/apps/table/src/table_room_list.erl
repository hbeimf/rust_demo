% table_room_list.erl

-module(table_room_list).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").
%% 定义记录结构
-include_lib("table/include/table.hrl").
-include_lib("glib/include/log.hrl").

-define(TABLE, room_list).

% test() -> 
%   List = lists:seq(1, 10),
%   lists:foreach(fun(_I) -> 
%       % create_room({Channel_id, RoomType}) ->  
%       room_sup:create_room({1, 1})
%   end, List),
%   lists:foreach(fun(_I) -> 
%       % create_room({Channel_id, RoomType}) ->  
%       room_sup:create_room({2, 2})
%   end, List),

%   % % into_room(RoomId, Uid),
%   % room:into_room(1, <<"123">>),
%   % room:into_room(1, <<"456">>),
%   % room:into_room(1, <<"789">>),
%   % room:into_room(1, <<"2233">>),

%   % room:into_room(2, <<"456123">>),
%   % room:into_room(2, <<"789123">>),
%   % room:into_room(2, <<"789123333">>),

%   % room:into_room(3, <<"a789123">>),
%   % room:into_room(3, <<"a789123333">>),

  

%   % Rooms = table_room_list:select_by_channel({1, 123, 10}),
%   % ?LOG(Rooms),
%   ok.

% room_id=0  %% 房间id 
%   , room_type = 0  %% 房间类型id 
%   , channel_id = 0 %% 渠道 id
%   , pid  %% 房间 pid
%   , room_position = [1,2,3,4] %% 默认值为4个凳子  [1,2,3,4],   [SeatId|OtherSeat] 每次取SeatId, 直到取完为空为止
%   , player_nums = 0 %% 房间人数
%   , ponds_pid % 鱼塘pid
%   % , record_pid % 上报记录pid
%   , bullet_rate = [] % 用户可以在房间里进行修改炮的单价
%   , min_launcher_level = 0 %房间内最小炮的id
%   , max_launcher_level = 0 %房间内最大炮的id

status() -> 
  ClientList = select(),
  lists:foreach(fun(Client) -> 
    ClientStatus = [
      {room_id, get_data(Client, room_id)}
    , {room_type, get_data(Client, room_type)}
    , {channel_id, get_data(Client, channel_id)}
    , {pid, get_data(Client, pid)}
    , {room_position, get_data(Client, room_position)}

    , {player_nums, get_data(Client, player_nums)}
    , {ponds_pid, get_data(Client, ponds_pid)}

    , {bullet_rate, get_data(Client, bullet_rate)}

    , {min_launcher_level, get_data(Client, min_launcher_level)}
    , {max_launcher_level, get_data(Client, max_launcher_level)}
    , {assist_pid, get_data(Client, assist_pid)}

    ],
    ?LOG({status, ClientStatus}),
    ok
  end, ClientList).


%%== 查询 =====================================

do(Q) ->
    F = fun() -> qlc:e(Q) end,
    {atomic,Val} = mnesia:transaction(F),
    Val.

% select * from table where channel_id = ? and room_type = ? and order by player_nums desc limit ?
select_by_channel({Channel_id, RoomType, Limit}) ->
  select_by_channel({Channel_id, RoomType, Limit}, 4).
select_by_channel({Channel_id, RoomType, Limit}, Player_nums) ->
      F = fun() ->
        Q = qlc:q([X || X <- mnesia:table(?TABLE),
                 X#?TABLE.channel_id =:= Channel_id,
                 X#?TABLE.room_type =:= RoomType,
                 X#?TABLE.player_nums =/= Player_nums
        ]),

        %% order by id
        %Q1 = qlc:e(qlc:keysort(1, Q, [{room_id}])),
        Q1 = qlc:e(qlc:keysort(6, Q, [{order, descending}])),
         %% limit
        QC = qlc:cursor(Q1),
        qlc:next_answers(QC, Limit)
    end,
    {atomic,Val} = mnesia:transaction(F),
    Val.

  

%% SELECT * FROM table
%% 选取所有列
select() ->
    do(qlc:q([X || X <- mnesia:table(?TABLE)])).

select(RoomId) ->
    do(qlc:q([X || X <- mnesia:table(?TABLE),
                X#?TABLE.room_id =:= RoomId
            ])).
select(player_nums, Num)->
    do(qlc:q([X || X <- mnesia:table(?TABLE),
                X#?TABLE.player_nums =/= 0
            ])).

 % table_room_list:select_room_by_channel(channel_id, 1, 2).
select_room_by_channel(channel_id, Channel_id, Limit) ->
    F = fun() ->
        Q = qlc:q([X || X <- mnesia:table(?TABLE),
                 X#?TABLE.channel_id =:= Channel_id
        ]),

        %% order by id
        %Q1 = qlc:e(qlc:keysort(1, Q, [{room_id}])),
        Q1 = qlc:e(qlc:keysort(6, Q, [{order, ascending}])),
         %% limit
        QC = qlc:cursor(Q1),
        qlc:next_answers(QC, Limit)
    end,
    {atomic,Val} = mnesia:transaction(F),
    Val.


get_data(Data, room_id) ->
      Data#?TABLE.room_id;
get_data(Data, room_type) ->
      Data#?TABLE.room_type;
get_data(Data, channel_id) ->
      Data#?TABLE.channel_id;
get_data(Data, pid) ->
      Data#?TABLE.pid;
get_data(Data, room_position) ->
      Data#?TABLE.room_position;
get_data(Data, ponds_pid) ->
      Data#?TABLE.ponds_pid;
% get_data(Data, record_pid) ->
%       Data#?TABLE.record_pid;
get_data(Data, bullet_rate) ->
      Data#?TABLE.bullet_rate;
get_data(Data, max_launcher_level) ->
      Data#?TABLE.max_launcher_level;
get_data(Data, min_launcher_level) -> 
      Data#?TABLE.min_launcher_level;
get_data(Data, player_nums) ->
      Data#?TABLE.player_nums;

get_data(Data, assist_pid) ->
      Data#?TABLE.assist_pid.




%% == 数据操作 ===============================================


%% 增加一行
% add(RoomId,  RoomType, Channel_id, Pid, SeatId, PlayNum, PondsPid, RecordPid) ->
%     add(RoomId,  RoomType, Channel_id, Pid, SeatId, PlayNum, PondsPid, RecordPid, []).

add(RoomId, RoomType, Channel_id, Pid, SeatId, PlayNum, 
    PondsPid, Bullet_Rate, Min_launcher_level, Max_launcher_level, Assist_pid) ->
    Row = #?TABLE{
        room_id = RoomId
        , room_type = RoomType
        , channel_id = Channel_id
        , pid = Pid
        , room_position = SeatId
        , player_nums = PlayNum
        , ponds_pid = PondsPid
        % , record_pid = RecordPid
        , bullet_rate = Bullet_Rate
        , max_launcher_level = Max_launcher_level
        , min_launcher_level = Min_launcher_level
        , assist_pid = Assist_pid
    },

    F = fun() ->
      mnesia:write(Row)
    end,
    mnesia:transaction(F).


% table_client_list:update(1, scene_id, 11).
update(Id, Key, Val) ->
    case select(Id) of
        [] ->
            ok;
        [Client|_] ->
            % Row = Client#?TABLE{scene_id = SceneId},
            Row = new_client(Client, Key, Val),
            update_row(Row)
    end.


% %% 房间列表
% -record(room_list, {
% 	room_id=0  %% 房间id 
% 	, room_type = 0  %% 房间类型id 
% 	, channel_id = 0 %% 渠道 id
% 	, pid  %% 房间 pid
% , room_position = [1,2,3,4] %% 默认值为4个凳子  [1,2,3,4],   [SeatId|OtherSeat] 每次取SeatId, 直到取完为空为止
% , player_nums = 0 %% 房间人数
% }).


new_client(Client, room_id, Val) ->
      Client#?TABLE{room_id = Val};
new_client(Client, room_type, Val) ->
      Client#?TABLE{room_type = Val};
new_client(Client, channel_id, Val) ->
      Client#?TABLE{channel_id = Val};
new_client(Client, pid, Val) ->
      Client#?TABLE{pid = Val};
new_client(Client, room_position, Val) ->
      Client#?TABLE{room_position = Val};
new_client(Client, player_nums, Val) ->
      Client#?TABLE{player_nums = Val};
new_client(Client, ponds_pid, Val) ->
      Client#?TABLE{ponds_pid = Val};
% new_client(Client, record_pid, Val) ->
%       Client#?TABLE{record_pid = Val};
new_client(Client, bullet_rate, Val) ->
      Client#?TABLE{bullet_rate = Val};

new_client(Client, max_launcher_level, Val) ->
      Client#?TABLE{max_launcher_level = Val};
new_client(Client, min_launcher_level, Val) ->
      Client#?TABLE{min_launcher_level = Val};

new_client(Client, assist_pid, Val) ->
      Client#?TABLE{assist_pid = Val};

new_client(Client, _, _) ->
      Client.

update_row(Row) ->
    F = fun() ->
            mnesia:write(Row)
    end,
    mnesia:transaction(F).

%% 删除一行
delete(Id) ->
    Oid = {?TABLE, Id},
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



%table_room_list:get_room_info(1).
get_room_info(Room_id)->
  Room_infos = select(Room_id),
  Map = case Room_infos of
        [Room|_]->
          Room_map = #{
            room_id => get_data(Room, room_id)
            ,room_type => get_data(Room, room_type)
            ,channel_id => get_data(Room, channel_id)
            ,pid => get_data(Room, pid)
            ,room_position => get_data(Room, room_position)
            ,ponds_pid => get_data(Room, ponds_pid)
            % ,record_pid => get_data(Room, record_pid)
            ,player_nums => get_data(Room, player_nums)
            ,bullet_rate => get_data(Room, bullet_rate)
            ,min_launcher_level => get_data(Room, min_launcher_level)
            ,max_launcher_level => get_data(Room, max_launcher_level)
            , assist_pid => get_data(Room, assist_pid)
          };
        _->
            #{}
    end,
    Map.
