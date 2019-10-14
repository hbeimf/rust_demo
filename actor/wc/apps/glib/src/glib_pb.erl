% glib_pb.erl
-module(glib_pb).
-compile(export_all).

-include_lib("glib/include/action.hrl").
-include_lib("glib/include/msg_proto.hrl").

-include_lib("glib/include/gw_proto.hrl").

% message VerifyReq { //请求认证 cmd=3  http
%                     string identity = 1; //用户身份
%                     string channel_id = 2;
% }
encode_VerifyReq(Identity, Channel_id)->
	VerifyReq = #'VerifyReq'{
		identity = Identity
		, channel_id = Channel_id
	},
	Pb = gw_proto:encode_msg(VerifyReq),
	Pb.



% message Msgs{
%     repeated Msg msgList = 1;
% }
encode_Msgs(MsgList)->
	Msgs = #'Msgs'{
		msgList = MsgList
	},
	Pb = msg_proto:encode_msg(Msgs),
	Pb.
decode_Msgs(DataBin) -> 
	#'Msgs'{msgList = MsgList} = msg_proto:decode_msg(DataBin,'Msgs'),
	{MsgList}.


% message Msg{
%     uint32 action = 1;
%     bytes  msgBody = 2;
%     string token = 3;
% }
msg(Action, MsgBody, Token) -> 
	#'Msg'{
		action = Action
		,msgBody = MsgBody
		,token = Token
	}.

encode_Msg(Action, MsgBody, Token)->
	Msg = #'Msg'{
		action = Action
		,msgBody = MsgBody
		,token = Token
	},
	Pb = msg_proto:encode_msg(Msg),
	Pb.
% glib_pb:decode_Msg(<<8,199,184,2,18,20,8,158,142,254,255,255,255,255,255,255,1,16,0,24,209,1,32,0,40,0,26,0>>).
decode_Msg(DataBin) -> 
	#'Msg'{action = Action, msgBody = MsgBody, token = Token} = msg_proto:decode_msg(DataBin,'Msg'),
	{Action, MsgBody, Token}.



% message Heartbeat {         //心跳消息
% }
encode_Heartbeat()->
	Heartbeat = #'Heartbeat'{},
	Pb = msg_proto:encode_msg(Heartbeat),
	Pb.


% message CommonStatus {
%     int32 code = 1;
%     string msg = 2;
%     int32 type = 3;
% }
encode_CommonStatus(Code, Msg, Type)->
	CommonStatus = #'CommonStatus'{
		code = Code
		,msg = Msg
		,type = Type
	},
	Pb = msg_proto:encode_msg(CommonStatus),
	Pb.
decode_CommonStatus(DataBin) -> 
	#'CommonStatus'{code = Code, msg = Msg, type = Type} = msg_proto:decode_msg(DataBin,'CommonStatus'),
	{Code, Msg, Type}.


% message BroadcastMessage {      //服务器端返回
%     uint32 broadType = 1;//类型1活动广告，2房间捕鱼
%     string msg = 2;//广告内容
%     uint32 langId = 3;//语言ID
%     repeated string params = 4;//语言ID对应的参数
%     uint32 priority = 5;//显示优先级
% }
encode_BroadcastMessage(BroadType, Msg, LangId, Params, Priority)->
	BroadcastMessage = #'BroadcastMessage'{
		broadType = BroadType
		,msg = Msg
		,langId = LangId
		,params = Params
		,priority = Priority
	},
	Pb = msg_proto:encode_msg(BroadcastMessage),
	Pb.
decode_BroadcastMessage(DataBin) -> 
	#'BroadcastMessage'{broadType = BroadType, msg = Msg, langId = LangId, params = Params, priority = Priority} = msg_proto:decode_msg(DataBin,'BroadcastMessage'),
	{BroadType, Msg, LangId, Params, Priority}.


% message BroadcastMessageList { //服务器端返回
%     repeated BroadcastMessage messageList = 1;//跑马灯广告列表
% }
encode_BroadcastMessageList(MessageList)->
	BroadcastMessageList = #'BroadcastMessageList'{
		messageList = MessageList
	},
	Pb = msg_proto:encode_msg(BroadcastMessageList),
	Pb.
decode_BroadcastMessageList(DataBin) -> 
	#'BroadcastMessageList'{messageList = MessageList} = msg_proto:decode_msg(DataBin,'BroadcastMessageList'),
	{MessageList}.


% message  LoginReq{   // 发送进入游戏 4008  CL_GAME_ENTER_GAME 对应 LoginReq
%     string identity = 1;//登陆服务器给的密钥
% }
encode_LoginReq(Identity)->
	LoginReq = #'LoginReq'{
		identity = Identity
	},
	Pb = msg_proto:encode_msg(LoginReq),
	Pb.
decode_LoginReq(DataBin) -> 
	#'LoginReq'{identity = Identity} = msg_proto:decode_msg(DataBin,'LoginReq'),
	{Identity}.


% message LoginRes{   // 接收初始化数据 4007  GAME_CL_SEND_INIT_DATA 对应 LoginRes
%     string uid = 1;
%     string name = 2;
%     string headUrl = 3;
%     string ip = 4;
%     uint64 money = 5;
%     float bangMoney = 6;
%     float bankMoney = 7;
%     string bankPassword = 8;
%     uint32 telephone_fare = 9;
%     uint32 serverTime = 10;
%     uint32 vipExp = 11;
%     string phoneNum = 12;
%     uint32 roomCard = 13;
%     string token = 14;
% }
encode_LoginRes(Uid, Name, HeadUrl, Ip, Money, BangMoney, BankMoney, BankPassword, Telephone_fare, ServerTime, VipExp, PhoneNum, RoomCard, Token)->
	LoginRes = #'LoginRes'{
		uid = Uid
		,name = Name
		,headUrl = HeadUrl
		,ip = Ip
		,money = Money
		,bangMoney = BangMoney
		,bankMoney = BankMoney
		,bankPassword = BankPassword
		,telephone_fare = Telephone_fare
		,serverTime = ServerTime
		,vipExp = VipExp
		,phoneNum = PhoneNum
		,roomCard = RoomCard
		,token = Token
	},
	Pb = msg_proto:encode_msg(LoginRes),
	Pb.
decode_LoginRes(DataBin) -> 
	#'LoginRes'{
		uid = Uid
		,name = Name
		,headUrl = HeadUrl
		,ip = Ip
		,money = Money
		,bangMoney = BangMoney
		,bankMoney = BankMoney
		,bankPassword = BankPassword
		,telephone_fare = Telephone_fare
		,serverTime = ServerTime
		,vipExp = VipExp
		,phoneNum = PhoneNum
		,roomCard = RoomCard
		,token = Token
	} =  msg_proto:decode_msg(DataBin,'LoginRes'),
	{Uid, Name, HeadUrl, Ip, Money, BangMoney, BankMoney, BankPassword, Telephone_fare, ServerTime, VipExp, PhoneNum, RoomCard, Token}.


% message RoomOnlineInfoRes{
%     //房间在线人数 50005
%     repeated RoomOnlineInfo roomOnlineInfo = 1;
% }
encode_RoomOnlineInfoRes(RoomOnlineInfo)->
	RoomOnlineInfoRes = #'RoomOnlineInfoRes'{
		roomOnlineInfo = RoomOnlineInfo
	},
	Pb = msg_proto:encode_msg(RoomOnlineInfoRes),
	Pb.
decode_RoomOnlineInfoRes(DataBin) -> 
	#'RoomOnlineInfoRes'{roomOnlineInfo = RoomOnlineInfo} =  msg_proto:decode_msg(DataBin,'RoomOnlineInfoRes'),
	{RoomOnlineInfo}.


% message RoomOnlineInfo{
%     uint32 type = 1;
%     uint32 playCount = 2;
% }
encode_RoomOnlineInfo(Type, PlayCount)->
	RoomOnlineInfo = #'RoomOnlineInfo'{
		type = Type
		,playCount = PlayCount
	},
	Pb = msg_proto:encode_msg(RoomOnlineInfo),
	Pb.
decode_RoomOnlineInfo(DataBin) -> 
	#'RoomOnlineInfo'{type = Type, playCount = PlayCount} =  msg_proto:decode_msg(DataBin,'RoomOnlineInfo'),
	{Type, PlayCount}.


% message RoomInfoReq {
%     uint32 type = 1; //请求进入房间类型 4029 CL_GAME_JOIN_M_ROOM 对应 
%     string uid = 2;
% //    int32  roomIndex = 3; //点击的房间下标
% }
encode_RoomInfoReq(Type, Uid )->
	RoomInfoReq = #'RoomInfoReq'{
		type = Type
		,uid = Uid
	},
	Pb = msg_proto:encode_msg(RoomInfoReq),
	Pb.
decode_RoomInfoReq(DataBin) -> 
	#'RoomInfoReq'{type = Type, uid = Uid} =  msg_proto:decode_msg(DataBin,'RoomInfoReq'),
	{Type, Uid}.


% message RoomInfoRes{      // 接收获取房间域名，连接socket 3001  SM_GATE_GAME_IP 对应  RoomInfoRes
%     uint32 enterKindId = 1;   // 0 正常 1 微信  默认0
%     uint32 gameType = 2;      // 微信用         默认0
%     string enterKindServerId = 3;  //  房间域名
%     uint32 enterKindPost = 4;    //  端口
% }
encode_RoomInfoRes(EnterKindId, GameType, EnterKindServerId, EnterKindPost)->
	RoomInfoRes = #'RoomInfoRes'{
		enterKindId = EnterKindId
		,gameType = GameType
		,enterKindServerId = EnterKindServerId
		,enterKindPost = EnterKindPost
	},
	Pb = msg_proto:encode_msg(RoomInfoRes),
	Pb.
decode_RoomInfoRes(DataBin) -> 
	#'RoomInfoRes'{
		enterKindId = EnterKindId
		,gameType = GameType
		,enterKindServerId = EnterKindServerId
		,enterKindPost = EnterKindPost
	} =  msg_proto:decode_msg(DataBin,'RoomInfoRes'),
	{EnterKindId, GameType, EnterKindServerId, EnterKindPost}.


% message LeaveGameReq {//请求进入房间类型 20003
%     uint32 type = 1; // 1：离开游戏 2：离开房间
% }
encode_LeaveGameReq(Type)->
	LeaveGameReq = #'LeaveGameReq'{
		type = Type
	},
	Pb = msg_proto:encode_msg(LeaveGameReq),
	Pb.
decode_LeaveGameReq(DataBin) -> 
	#'LeaveGameReq'{
		type = Type
	} =  msg_proto:decode_msg(DataBin,'LeaveGameReq'),
	{Type}.



% message LeaveGameRes {//请求进入房间类型 20004
%     int32 code = 1; // 0：成功 1：失败
%     string msg = 2;
% }
encode_LeaveGameRes(Code, Msg)->
	LeaveGameRes = #'LeaveGameRes'{
		code = Code
		,msg = Msg
	},
	Pb = msg_proto:encode_msg(LeaveGameRes),
	Pb.
decode_LeaveGameRes(DataBin) -> 
	#'LeaveGameRes'{
		code = Code
		,msg = Msg
	} =  msg_proto:decode_msg(DataBin,'LeaveGameRes'),
	{Code, Msg}.


% message NotifyLeaveGameRes {//请求进入房间类型 25004
%     uint32 seatID = 1;          //座位id
% }
encode_NotifyLeaveGameRes(SeatID)->
	NotifyLeaveGameRes = #'NotifyLeaveGameRes'{
		seatID = SeatID
	},
	Pb = msg_proto:encode_msg(NotifyLeaveGameRes),
	Pb.
decode_NotifyLeaveGameRes(DataBin) -> 
	#'NotifyLeaveGameRes'{
		seatID = SeatID
	} =  msg_proto:decode_msg(DataBin,'NotifyLeaveGameRes'),
	{SeatID}.


% message NotifyEnterGameRes {//请求进入房间类型 25002
%     string uid = 1;
%     string name = 2;
%     string headUrl = 3;
%     string ip = 4;
%     float money = 5;
%     float bangMoney = 6;
%     uint32 launcherType = 7;
%     uint32 rateIndex = 8;
%     uint32 energy = 9;
%     uint32 seat = 10;
%     uint32 roomCard = 11;
% }
encode_NotifyEnterGameRes(Uid, Name, HeadUrl, Ip, Money, BangMoney, LauncherType, RateIndex, Energy, Seat, RoomCard)->
	NotifyEnterGameRes = #'NotifyEnterGameRes'{
		uid = Uid
		,name = Name
		,headUrl = HeadUrl
		,ip = Ip
		,money = Money
		,bangMoney = BangMoney
		,launcherType = LauncherType
		,rateIndex = RateIndex
		,energy = Energy
		,seat = Seat
		,roomCard = RoomCard
	},
	Pb = msg_proto:encode_msg(NotifyEnterGameRes),
	Pb.
decode_NotifyEnterGameRes(DataBin) -> 
	#'NotifyEnterGameRes'{
		uid = Uid
		,name = Name
		,headUrl = HeadUrl
		,ip = Ip
		,money = Money
		,bangMoney = BangMoney
		,launcherType = LauncherType
		,rateIndex = RateIndex
		,energy = Energy
		,seat = Seat
		,roomCard = RoomCard
	} =  msg_proto:decode_msg(DataBin,'NotifyEnterGameRes'),
	{Uid, Name, HeadUrl, Ip, Money, BangMoney, LauncherType, RateIndex, Energy, Seat, RoomCard}.


% message NotifyState {//更新用户信息 25007
%     uint32 seatID = 1;
%     uint64 money = 2;
%     uint64 bangMoney = 3;
% }
encode_NotifyState(SeatID, Money, BangMoney)->
	NotifyState = #'NotifyState'{
		seatID = SeatID
		,money = Money
		,bangMoney = BangMoney
	},
	Pb = msg_proto:encode_msg(NotifyState),
	Pb.
decode_NotifyState(DataBin) -> 
	#'NotifyState'{
		seatID = SeatID
		,money = Money
		,bangMoney = BangMoney
	} =  msg_proto:decode_msg(DataBin,'NotifyState'),
	{SeatID, Money, BangMoney}.


% message FireRes{  // 接收子弹  40008
%     repeated BulletItem bulletItemList = 1;
%     uint32 launcherType = 2;
%     uint32 energy = 3;
%     uint32 reboundCount = 4;
%     uint32 lockFishID = 5;
%     uint64 gold = 6;
%     uint32 targetX = 7;
%     uint32 targetY = 8;
%     uint32 bulletID = 9;
%     uint32 seatID = 10;
% }
encode_FireRes(BulletItemList, LauncherType, Energy, ReboundCount, LockFishID, Gold, TargetX, TargetY, BulletID, SeatID)->
	FireRes = #'FireRes'{
		bulletItemList = BulletItemList
		,launcherType = LauncherType
		,energy = Energy
		,reboundCount = ReboundCount
		,lockFishID = LockFishID
		,gold = Gold
		,targetX = TargetX
		,targetY = TargetY
		,bulletID = BulletID
		,seatID = SeatID
	},
	Pb = msg_proto:encode_msg(FireRes),
	Pb.
decode_FireRes(DataBin) -> 
	#'FireRes'{
		bulletItemList = BulletItemList
		,launcherType = LauncherType
		,energy = Energy
		,reboundCount = ReboundCount
		,lockFishID = LockFishID
		,gold = Gold
		,targetX = TargetX
		,targetY = TargetY
		,bulletID = BulletID
		,seatID = SeatID
	} =  msg_proto:decode_msg(DataBin,'FireRes'),
	{BulletItemList, LauncherType, Energy, ReboundCount, LockFishID, Gold, TargetX, TargetY, BulletID, SeatID}.


%  message FireReq{  //发射子弹 40007
%     int32 degree = 1;
%     uint32 lockedFishID= 2;
%     uint32 bulletID = 3;
%     uint32 targetX = 4;
%     uint32 targetY = 5;
%  }
encode_FireReq(Degree, LockedFishID, BulletID, TargetX, TargetY)->
	FireReq = #'FireReq'{
		degree = Degree
		,lockedFishID = LockedFishID
		,bulletID = BulletID
		,targetX = TargetX
		,targetY = TargetY
	},
	Pb = msg_proto:encode_msg(FireReq),
	Pb.
decode_FireReq(DataBin) -> 
	#'FireReq'{
		degree = Degree
		,lockedFishID = LockedFishID
		,bulletID = BulletID
		,targetX = TargetX
		,targetY = TargetY
	} =  msg_proto:decode_msg(DataBin,'FireReq'),
	{Degree, LockedFishID, BulletID, TargetX, TargetY}.


%  message BulletItem{ // 子弹结构
%     uint32 bulletID = 1;
%     int32 degree = 2;
%  }

get_BulletItem(BulletID, Degree)->
	BulletItem = #'BulletItem'{
		bulletID = BulletID
		,degree = Degree
	},
	BulletItem.

encode_BulletItem(BulletID, Degree)->
	BulletItem = #'BulletItem'{
		bulletID = BulletID
		,degree = Degree
	},
	Pb = msg_proto:encode_msg(BulletItem),
	Pb.
decode_BulletItem(DataBin) -> 
	#'BulletItem'{
		bulletID = BulletID
		,degree = Degree
	} =  msg_proto:decode_msg(DataBin,'BulletItem'),
	{BulletID, Degree}.


% message IntoRoomReq {       //进入房间 40000
%     string uid = 1;
%     uint32 roomId = 2;      //房间号
%     uint32 type = 3;
% }
encode_IntoRoomReq(Uid, RoomId, Type)->
	IntoRoomReq = #'IntoRoomReq'{
		uid = Uid
		,roomId = RoomId
		,type = Type
	},
	Pb = msg_proto:encode_msg(IntoRoomReq),
	Pb.
decode_IntoRoomReq(DataBin) -> 
	#'IntoRoomReq'{
		uid = Uid
		,roomId = RoomId
		,type = Type
	} =  msg_proto:decode_msg(DataBin,'IntoRoomReq'),
	{Uid, RoomId, Type}.


% message IntoRoomRes {       //接收进入捕鱼战斗 40001 GAME_CL_FISH_SCREEN  收到这条消息才进入战斗
%     int32 bTableTypeID = 1;      //其实就是 room_id
%     int32 backgroundImage = 2;   // 对应的是index   默认是0
%     int32 launcherType = 3;      // 炮id
%     uint32 seatID = 4;          //座位id
%     uint32 rateIndex = 5;       //当前倍率
%     uint32 match = 6;           //默认0
%     uint64 matchGold = 7;       //默认0
%     uint32 minRate = 8;         //
%     uint32 maxRate = 9;
%     uint32 roomId = 10;          //默认0
%     string roomName = 11;
%     uint32 endTime = 12;         //timestamp
% }
encode_IntoRoomRes(BTableTypeID, BackgroundImage, LauncherType, SeatID, RateIndex, Match, MatchGold, MinRate, MaxRate, RoomId, RoomName, EndTime)->
	IntoRoomRes = #'IntoRoomRes'{
		bTableTypeID = BTableTypeID
		,backgroundImage = BackgroundImage
		,launcherType = LauncherType
		,seatID = SeatID
		,rateIndex = RateIndex
		,match = Match
		,matchGold = MatchGold
		,minRate = MinRate
		,maxRate = MaxRate
		,roomId = RoomId
		,roomName = RoomName
		,endTime = EndTime
	},
	Pb = msg_proto:encode_msg(IntoRoomRes),
	Pb.
decode_IntoRoomRes(DataBin) -> 
	#'IntoRoomRes'{
		bTableTypeID = BTableTypeID
		,backgroundImage = BackgroundImage
		,launcherType = LauncherType
		,seatID = SeatID
		,rateIndex = RateIndex
		,match = Match
		,matchGold = MatchGold
		,minRate = MinRate
		,maxRate = MaxRate
		,roomId = RoomId
		,roomName = RoomName
		,endTime = EndTime
	} =  msg_proto:decode_msg(DataBin,'IntoRoomRes'),
	{BTableTypeID, BackgroundImage, LauncherType, SeatID, RateIndex, Match, MatchGold, MinRate, MaxRate, RoomId, RoomName, EndTime}.


% message SyncFishes{  //接收同步鱼 40002   NetCmdSyncFish pondfish
%    repeated SyncFishData fishList = 1;
% }
get_SyncFishes(FishList)->
	SyncFishes = #'SyncFishes'{
		fishList = FishList
	},
	SyncFishes.
encode_SyncFishes(FishList)->
	SyncFishes = #'SyncFishes'{
		fishList = FishList
	},
	Pb = msg_proto:encode_msg(SyncFishes),
	Pb.
decode_SyncFishes(DataBin) -> 
	#'SyncFishes'{
		fishList = FishList
	} =  msg_proto:decode_msg(DataBin,'SyncFishes'),
	{FishList}.


% message AddFishes{  // 接收鱼   40004
%     uint32 groupID = 1;
%     uint32 pathID = 2;
%     uint32 startID = 3;
% }
encode_AddFishes(GroupID, PathID, StartID)->
	AddFishes = #'AddFishes'{
		groupID = GroupID
		,pathID = PathID
		,startID = StartID
	},
	Pb = msg_proto:encode_msg(AddFishes),
	Pb.
decode_AddFishes(DataBin) -> 
	#'AddFishes'{
		groupID = GroupID
		,pathID = PathID
		,startID = StartID
	} =  msg_proto:decode_msg(DataBin,'AddFishes'),
	{GroupID, PathID, StartID}.


% message CatchedFishReq { //通知服务器命中了鱼
%     string userId=1;
%     uint32 fishID = 2;
%     uint32 bulletID = 3;//子弹id
%     repeated uint32 catchedFishs = 4; //被网中的鱼
% }
encode_CatchedFishReq(UserId, FishID, BulletID, CatchedFishs)->
	CatchedFishReq = #'CatchedFishReq'{
		userId = UserId
		,fishID = FishID
		,bulletID = BulletID
		,catchedFishs = CatchedFishs
	},
	Pb = msg_proto:encode_msg(CatchedFishReq),
	Pb.
decode_CatchedFishReq(DataBin) -> 
	#'CatchedFishReq'{
		userId = UserId
		,fishID = FishID
		,bulletID = BulletID
		,catchedFishs = CatchedFishs
	} =  msg_proto:decode_msg(DataBin,'CatchedFishReq'),
	{UserId, FishID, BulletID, CatchedFishs}.


% message CatchedFishRes{
%     uint32 bulletID = 1;//子弹id
%     uint64 gold=2;      //
%     uint32 isRemoveBullet = 3;
%     float totalNum = 4;
%     uint32 seatID = 5;
%     repeated CatchedFishes catchedFishes = 6; //命中后的事件
% }
get_CatchedFishRes(BulletID, Gold, IsRemoveBullet, TotalNum, SeatID, CatchedFishes)->
	CatchedFishRes = #'CatchedFishRes'{
		bulletID = BulletID
		,gold = Gold
		,isRemoveBullet = IsRemoveBullet
		,totalNum = TotalNum
		,seatID = SeatID
		,catchedFishes = CatchedFishes
	},	
	CatchedFishRes.
encode_CatchedFishRes(BulletID, Gold, IsRemoveBullet, TotalNum, SeatID, CatchedFishes)->
	CatchedFishRes = #'CatchedFishRes'{
		bulletID = BulletID
		,gold = Gold
		,isRemoveBullet = IsRemoveBullet
		,totalNum = TotalNum
		,seatID = SeatID
		,catchedFishes = CatchedFishes
	},
	Pb = msg_proto:encode_msg(CatchedFishRes),
	Pb.
decode_CatchedFishRes(DataBin) -> 
	#'CatchedFishRes'{
		bulletID = BulletID
		,gold = Gold
		,isRemoveBullet = IsRemoveBullet
		,totalNum = TotalNum
		,seatID = SeatID
		,catchedFishes = CatchedFishes
	} =  msg_proto:decode_msg(DataBin,'CatchedFishRes'),
	{BulletID, Gold, IsRemoveBullet, TotalNum, SeatID, CatchedFishes}.


% message CatchedFishes{     //命中后的事件
%     uint32 catchEvent = 1;
%     uint32 fishID = 2;
%     uint32 rewardID = 3;
%     uint32 lightingFishID = 4;
% }
get_catchedFishes(CatchEvent, FishID, RewardID, LightingFishID)->
	CatchedFishes = #'CatchedFishes'{
		catchEvent = CatchEvent
		,fishID = FishID
		,rewardID = RewardID
		,lightingFishID = LightingFishID
	},
	CatchedFishes.
encode_CatchedFishes(CatchEvent, FishID, RewardID, LightingFishID)->
	CatchedFishes = #'CatchedFishes'{
		catchEvent = CatchEvent
		,fishID = FishID
		,rewardID = RewardID
		,lightingFishID = LightingFishID
	},
	Pb = msg_proto:encode_msg(CatchedFishes),
	Pb.
decode_CatchedFishes(DataBin) -> 
	#'CatchedFishes'{
		catchEvent = CatchEvent
		,fishID = FishID
		,rewardID = RewardID
		,lightingFishID = LightingFishID
	} =  msg_proto:decode_msg(DataBin,'CatchedFishes'),
	{CatchEvent, FishID, RewardID, LightingFishID}.


% message ClearSceneRes{
%     uint32 clearType = 1;  //清除屏幕
% }
encode_ClearSceneRes(ClearType)->
	ClearSceneRes = #'ClearSceneRes'{
		clearType = ClearType
	},
	Pb = msg_proto:encode_msg(ClearSceneRes),
	Pb.
decode_ClearSceneRes(DataBin) -> 
	#'ClearSceneRes'{
		clearType = ClearType
	} =  msg_proto:decode_msg(DataBin,'ClearSceneRes'),
	{ClearType}.


% message ChangeClientRateReq{
%     uint32 opt = 1; //0：减法操作  1：加法操作
% }
encode_ChangeClientRateReq(Opt)->
	ChangeClientRateReq = #'ChangeClientRateReq'{
		opt = Opt
	},
	Pb = msg_proto:encode_msg(ChangeClientRateReq),
	Pb.
decode_ChangeClientRateReq(DataBin) -> 
	#'ChangeClientRateReq'{
		opt = Opt
	} =  msg_proto:decode_msg(DataBin,'ChangeClientRateReq'),
	{Opt}.


% message ChangeClientRateRes{
%     uint32 seatID = 1;
%     uint32 isCanUseRate = 2;
%     uint32 rateIndex = 3;
% }
encode_ChangeClientRateRes(SeatID, IsCanUseRate, RateIndex)->
	ChangeClientRateRes = #'ChangeClientRateRes'{
		seatID = SeatID
		,isCanUseRate = IsCanUseRate
		,rateIndex = RateIndex
	},
	Pb = msg_proto:encode_msg(ChangeClientRateRes),
	Pb.
decode_ChangeClientRateRes(DataBin) -> 
	#'ChangeClientRateRes'{
		seatID = SeatID
		,isCanUseRate = IsCanUseRate
		,rateIndex = RateIndex
	} =  msg_proto:decode_msg(DataBin,'ChangeClientRateRes'),
	{SeatID, IsCanUseRate, RateIndex}.


% message ChangeClientRateTypeReq{        //客户端发送修改倍率
%     uint32 seatID = 1;
%     uint32 rateIndex = 2;
% }
encode_ChangeClientRateTypeReq(SeatID, RateIndex)->
	ChangeClientRateTypeReq = #'ChangeClientRateTypeReq'{
		seatID = SeatID
		,rateIndex = RateIndex
	},
	Pb = msg_proto:encode_msg(ChangeClientRateTypeReq),
	Pb.
decode_ChangeClientRateTypeReq(DataBin) -> 
	#'ChangeClientRateTypeReq'{
		seatID = SeatID
		,rateIndex = RateIndex
	} =  msg_proto:decode_msg(DataBin,'ChangeClientRateTypeReq'),
	{SeatID, RateIndex}.


% message ItemData {
%     uint32 itemId = 1;
%     uint32 count = 2;
%     int32 expried = 3;// 过期时间
% }
encode_ItemData(ItemId, Count, Expried)->
	ItemData = #'ItemData'{
		itemId = ItemId
		,count = Count
		,expried = Expried
	},
	Pb = msg_proto:encode_msg(ItemData),
	Pb.
decode_ItemData(DataBin) -> 
	#'ItemData'{
		itemId = ItemId
		,count = Count
		,expried = Expried
	} =  msg_proto:decode_msg(DataBin,'ItemData'),
	{ItemId, Count, Expried}.


% message SyncFishData{       // 同步鱼结构
%     uint32 fishID = 1;
%     uint32 groupID = 2;
%     float fishTime = 3;
%     uint32 pathGroup = 4;// path_id
%     uint32 pathIdx = 5;// path_id
%     bool isActiveEvent = 6;  //   this.IsActiveEvent = 1 == t.readByte()
%     uint32 elapsedTime = 7;
%     uint32 package = 8;
%     uint32 specialType = 9;
%     uint32 delayScaling = 10;
%     uint32 delayDuration1 = 11;
%     uint32 delayDuration2 = 12;
%     uint32 delayDuration3 = 13;
%     uint32 delayCurrentTime = 14;
%  }

get_SyncFishData(FishID, GroupID, FishTime, PathGroup, PathIdx, IsActiveEvent, ElapsedTime, Package, SpecialType, DelayScaling, DelayDuration1, DelayDuration2, DelayDuration3, DelayCurrentTime)->
	SyncFishData = #'SyncFishData'{
		fishID = FishID
		,groupID = GroupID
		,fishTime = FishTime
		,pathGroup = PathGroup
		,pathIdx = PathIdx
		,isActiveEvent = IsActiveEvent
		,elapsedTime = ElapsedTime
		,package = Package
		,specialType = SpecialType
		,delayScaling = DelayScaling
		,delayDuration1 = DelayDuration1
		,delayDuration2 = DelayDuration2
		,delayDuration3 = DelayDuration3
		,delayCurrentTime = DelayCurrentTime
	},
	SyncFishData.
encode_SyncFishData(FishID, GroupID, FishTime, PathGroup, PathIdx, IsActiveEvent, ElapsedTime, Package, SpecialType, DelayScaling, DelayDuration1, DelayDuration2, DelayDuration3, DelayCurrentTime)->
	SyncFishData = #'SyncFishData'{
		fishID = FishID
		,groupID = GroupID
		,fishTime = FishTime
		,pathGroup = PathGroup
		,pathIdx = PathIdx
		,isActiveEvent = IsActiveEvent
		,elapsedTime = ElapsedTime
		,package = Package
		,specialType = SpecialType
		,delayScaling = DelayScaling
		,delayDuration1 = DelayDuration1
		,delayDuration2 = DelayDuration2
		,delayDuration3 = DelayDuration3
		,delayCurrentTime = DelayCurrentTime
	},
	Pb = msg_proto:encode_msg(SyncFishData),
	Pb.
decode_SyncFishData(DataBin) -> 
	#'SyncFishData'{
		fishID = FishID
		,groupID = GroupID
		,fishTime = FishTime
		,pathGroup = PathGroup
		,pathIdx = PathIdx
		,isActiveEvent = IsActiveEvent
		,elapsedTime = ElapsedTime
		,package = Package
		,specialType = SpecialType
		,delayScaling = DelayScaling
		,delayDuration1 = DelayDuration1
		,delayDuration2 = DelayDuration2
		,delayDuration3 = DelayDuration3
		,delayCurrentTime = DelayCurrentTime
	} =  msg_proto:decode_msg(DataBin,'SyncFishData'),
	{FishID, GroupID, FishTime, PathGroup, PathIdx, IsActiveEvent, ElapsedTime, Package, SpecialType, DelayScaling, DelayDuration1, DelayDuration2, DelayDuration3, DelayCurrentTime}.


% message ChangeLauncherReq{  //换炮发送
%      uint32 seatID = 1;         // 座位id
%      uint32 launcherType = 2;   // 炮id
% }
encode_ChangeLauncherReq(SeatID, LauncherType)->
	ChangeLauncherReq = #'ChangeLauncherReq'{
		seatID = SeatID
		,launcherType = LauncherType
	},
	Pb = msg_proto:encode_msg(ChangeLauncherReq),
	Pb.
decode_ChangeLauncherReq(DataBin) -> 
	#'ChangeLauncherReq'{
		seatID = SeatID
		,launcherType = LauncherType
	} =  msg_proto:decode_msg(DataBin,'ChangeLauncherReq'),
	{SeatID, LauncherType}.


% message ChangeLauncherRes{  //换炮返回
%      uint32 seatID = 1;
%      uint32 launcherType = 2;
% }
encode_ChangeLauncherRes(SeatID, LauncherType)->
	ChangeLauncherRes = #'ChangeLauncherRes'{
		seatID = SeatID
		,launcherType = LauncherType
	},
	Pb = msg_proto:encode_msg(ChangeLauncherRes),
	Pb.
decode_ChangeLauncherRes(DataBin) -> 
	#'ChangeLauncherRes'{
		seatID = SeatID
		,launcherType = LauncherType
	} =  msg_proto:decode_msg(DataBin,'ChangeLauncherRes'),
	{SeatID, LauncherType}.



% // 绑定机器人 服务器下发
% message BindRobotReq {
%     uint32 position = 1;
%     string userId = 2;
% }
encode_BindRobotReq(Position, UserId)->
	BindRobotReq = #'BindRobotReq'{
		position = Position
		,userId = UserId
	},
	Pb = msg_proto:encode_msg(BindRobotReq),
	Pb.
decode_BindRobotReq(DataBin) -> 
	#'BindRobotReq'{
		position = Position
		,userId = UserId
	} =  msg_proto:decode_msg(DataBin,'BindRobotReq'),
	{Position, UserId}.


% // 绑定机器人成功
% message BindRobotSuccessRes {
%     uint32 position = 1;
%     string userId = 2;
% }
encode_BindRobotSuccessRes(Position, UserId)->
	BindRobotSuccessRes = #'BindRobotSuccessRes'{
		position = Position
		,userId = UserId
	},
	Pb = msg_proto:encode_msg(BindRobotSuccessRes),
	Pb.
decode_BindRobotSuccessRes(DataBin) -> 
	#'BindRobotSuccessRes'{
		position = Position
		,userId = UserId
	} =  msg_proto:decode_msg(DataBin,'BindRobotSuccessRes'),
	{Position, UserId}.


% // 解绑机器人  服务器下发
% message UnbindRobotReq {
%     uint32 position = 1;
%     string userId = 2;
% }
encode_UnbindRobotReq(Position, UserId)->
	UnbindRobotReq = #'UnbindRobotReq'{
		position = Position
		,userId = UserId
	},
	Pb = msg_proto:encode_msg(UnbindRobotReq),
	Pb.
decode_UnbindRobotReq(DataBin) -> 
	#'UnbindRobotReq'{
		position = Position
		,userId = UserId
	} =  msg_proto:decode_msg(DataBin,'UnbindRobotReq'),
	{Position, UserId}.


% // 解绑机器人成功
% message UnbindRobotSuccessRes {
%     uint32 position = 1;
%     string userId = 2;
% }
encode_UnbindRobotSuccessRes(Position, UserId)->
	UnbindRobotSuccessRes = #'UnbindRobotSuccessRes'{
		position = Position
		,userId = UserId
	},
	Pb = msg_proto:encode_msg(UnbindRobotSuccessRes),
	Pb.
decode_UnbindRobotSuccessRes(DataBin) -> 
	#'UnbindRobotSuccessRes'{
		position = Position
		,userId = UserId
	} =  msg_proto:decode_msg(DataBin,'UnbindRobotSuccessRes'),
	{Position, UserId}.


% // 牌局纪录
% message GameRecordReq {
% }
encode_GameRecordReq(Position, UserId)->
	GameRecordReq = #'GameRecordReq'{},
	Pb = msg_proto:encode_msg(GameRecordReq),
	Pb.


% // 牌局纪录
% message GameRecordRes {
%     repeated GameRecord gameRecord = 1;
% }
encode_GameRecordRes(GameRecord)->
	GameRecordRes = #'GameRecordRes'{
		gameRecord = GameRecord
	},
	Pb = msg_proto:encode_msg(GameRecordRes),
	Pb.
decode_GameRecordRes(DataBin) -> 
	#'GameRecordRes'{
		gameRecord = GameRecord
	} =  msg_proto:decode_msg(DataBin,'GameRecordRes'),
	{GameRecord}.


% // 牌局纪录
% message GameRecord {
%     string roundId = 1; // 场景编号
%     int32 roomType = 2; // 房间类型
%     int32 allBet = 3; // 子弹总价
%     int32 allWin = 4; // 鱼的总价
%     int32 result = 5; // 赢利结果
%     string startTime = 6; // 开始时间
%     string endTime = 7; // 结束时间
% }
encode_GameRecord(RoundId, RoomType, AllBet, AllWin, Result, StartTime, EndTime)->
	GameRecord = #'GameRecord'{
		roundId = RoundId
		,roomType = RoomType
		,allBet = AllBet
		,allWin = AllWin
		,result = Result
		,startTime = StartTime
		,endTime = EndTime
	},
	Pb = msg_proto:encode_msg(GameRecord),
	Pb.
decode_GameRecord(DataBin) -> 
	#'GameRecord'{
		roundId = RoundId
		,roomType = RoomType
		,allBet = AllBet
		,allWin = AllWin
		,result = Result
		,startTime = StartTime
		,endTime = EndTime
	} =  msg_proto:decode_msg(DataBin,'GameRecord'),
	{RoundId, RoomType, AllBet, AllWin, Result, StartTime, EndTime}.