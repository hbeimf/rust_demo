%% 定义记录结构

%% 房间列表
-record(room_list, {
	room_id=0  %% 房间id 
	, room_type = 0  %% 房间类型id 
	, channel_id = 0 %% 渠道 id
	, pid  %% 房间 pid
	, room_position = [1,2,3,4] %% 默认值为4个凳子  [1,2,3,4],   [SeatId|OtherSeat] 每次取SeatId, 直到取完为空为止
 	, player_nums = 0 %% 房间人数
 	, ponds_pid % 鱼塘pid
 	, assist_pid  %%  房间助手 pid 
 	% , record_pid % 上报记录pid
 	, bullet_rate = [] % 用户可以在房间里进行修改炮的单价
 	, min_launcher_level = 0 %房间内最小炮的id
 	, max_launcher_level = 0 %房间内最大炮的id
}).





