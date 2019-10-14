-ifndef(ACTION_ID).
-define(ACTION_ID,true).

%     const HeartBeat = 1001;
-define(HeartBeat, 1001).  %% 心跳 

%     const CommonStatus = 999999;
-define(CommonStatus, 999999).  %% 

%     const LoginReq = 4008;
-define(LoginReq, 4008).  %% 

%     const LoginRes = 4007;
-define(LoginRes, 4007).  %% 

%     const RoomInfoReq = 4029;
-define(RoomInfoReq, 4029).  %% 


%     const RoomInfoRes = 3001;
-define(RoomInfoRes, 3001).  %% 
%     const RoomOnlineInfoRes = 50005;
-define(RoomOnlineInfoRes, 50005).  %% 

%     const IntoRoomReq = 40000;
-define(IntoRoomReq, 40000).  %% 

%     const IntoRoomRes = 40001;
-define(IntoRoomRes, 40001).  %% 

%     const SyncFishes = 40002;
-define(SyncFishes, 40002).  %% 

%     const AddFishes = 40004;
-define(AddFishes, 40004).  %% 

%     const LeaveGameReq = 20003;
-define(LeaveGameReq, 20003).  %% 

%     const LeaveGameRes = 20004;
-define(LeaveGameRes, 20004).  %% 

%     const FireRes = 40008;
-define(FireRes, 40008).  %% 

%     const FireReq = 40007;
-define(FireReq, 40007).  %% 

%     const NotifyLeaveGame = 25004;
-define(NotifyLeaveGame, 25004).  %% 


%     const NotifyEnterGameRes = 25002;
-define(NotifyEnterGameRes, 25002).  %% 

%     const NotifyState=25007;
-define(NotifyState, 25007).  %% 

%     const CatchedFishReq = 40035;
-define(CatchedFishReq, 40035).  %% 

%     const CatchedFishRes = 40006;
-define(CatchedFishRes, 40006).  %% 

%     const ClearSceneRes = 40031;
-define(ClearSceneRes, 40031).  %% 

%     const ChangeClientRateReq = 40019;
-define(ChangeClientRateReq, 40019).  %% 

%     const ChangeClientRateRes = 40020;
-define(ChangeClientRateRes, 40020).  %% 

%     const ChangeClientRateTypeReq = 40021;
-define(ChangeClientRateTypeReq, 40021).  %% 

%     const ChangeLauncherReq = 40010;
-define(ChangeLauncherReq, 40010).  %% 

%     const ChangeLauncherRes = 40011;
-define(ChangeLauncherRes, 40011).  %% 

%     const BINDROBOTREQ = 50001;
-define(BINDROBOTREQ, 50001).  %% 

%     const BINDROBOTSUCCESSRES = 50002;
-define(BINDROBOTSUCCESSRES, 50002).  %% 

%     const UNBINDROBOTREQ= 50003;
-define(UNBINDROBOTREQ, 50003).  %% 

%     const UNBINDROBOTSUCCESSRES = 50004;
-define(UNBINDROBOTSUCCESSRES, 50004).  %% 

%     const GAMERECOREDREQ=50006;
-define(GAMERECOREDREQ, 50006).  %% 

%     const GAMERECOREDRES=50007;
-define(GAMERECOREDRES, 50007).  %% 


-endif.

% <?php

% namespace app\Conf;

% class ProtocolCode {

%     const HeartBeat = 1001;
%     const CommonStatus = 999999;
%     const LoginReq = 4008;
%     const LoginRes = 4007;
%     const RoomInfoReq = 4029;
%     const RoomInfoRes = 3001;
%     const RoomOnlineInfoRes = 50005;


%     const IntoRoomReq = 40000;
%     const IntoRoomRes = 40001;
%     const SyncFishes = 40002;
%     const AddFishes = 40004;
%     const LeaveGameReq = 20003;
%     const LeaveGameRes = 20004;
%     const FireRes = 40008;
%     const FireReq = 40007;
%     const NotifyLeaveGame = 25004;
%     const NotifyEnterGameRes = 25002;
%     const NotifyState=25007;
%     const CatchedFishReq = 40035;
%     const CatchedFishRes = 40006;
%     const ClearSceneRes = 40031;

%     const ChangeClientRateReq = 40019;
%     const ChangeClientRateRes = 40020;
%     const ChangeClientRateTypeReq = 40021;
%     const ChangeLauncherReq = 40010;
%     const ChangeLauncherRes = 40011;


%     const BINDROBOTREQ = 50001;
%     const BINDROBOTSUCCESSRES = 50002;
%     const UNBINDROBOTREQ= 50003;
%     const UNBINDROBOTSUCCESSRES = 50004;

%     const GAMERECOREDREQ=50006;
%     const GAMERECOREDRES=50007;

% }
