-ifndef(CMD_GS).
-define(CMD_GS,true).

-define(CMD_GS_1, 1).  %% 广播
-define(CMD_GS_2, 2).  %% 广播

-define(CMD_GS_3, 3).  %% 心跳
-define(CMD_GS_3_REPLY, 4).  %% 心跳

-define(CMD_GS_5, 5).  %% 通知客户端下线

-define(CMD_GS_6, 6).  %% 踢客户端下线

-define(CMD_GS_7, 7).  %% 获取在线用户数 cmd=7
-define(CMD_GS_7_REPLY, 8).  %% 
-define(CMD_GS_9, 9).  %% 判断用户是否在线请求
-define(CMD_GS_9_REPLY, 10).  %% 

-define(CMD_GS_11, 11).  %% 对 ip 进行封禁操作

-define(CMD_GS_12, 12).  %% 对游戏服进行广播


-define(CMD_GS_13, 13).  %% 判断用户是否在游戏中
-define(CMD_GS_13_REPLY, 14).  %% 判断用户是否在游戏中 reply



-endif.