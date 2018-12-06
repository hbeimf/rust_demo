-ifndef(GATEWAY_CMD).
-define(GATEWAY_CMD,true).

-define(GATEWAY_CMD_REPORT, 1001).  %% 网关上报信息到控制中心节点
-define(GATEWAY_CMD_GS_REPORT, 1002).  %% 游戏服

-define(GATEWAY_CMD_SEND_CLIENT_LOGOUT, 1003).  %% 向gwc发送uid已断线
-define(GATEWAY_CMD_SEND_CLIENT_LOGIN, 1005).  %% 向gwc发送uid已建立连接

-define(GATEWAY_CMD_BROADCAST_1, 1007).  %% 广播1
-define(GATEWAY_CMD_BROADCAST_2, 1009).  %% 广播2


-define(GATEWAY_CMD_GS_HALT, 1011).  %% 游戏服节点崩溃了


-define(GATEWAY_CMD_TICK_USER, 1013).  %% 踢客户端下线

-define(GATEWAY_CMD_USER_LOGIN_OTHER_PLACE, 1015).  %% 用户在异地登录了


-define(GATEWAY_CMD_FORBIDDEN_IP, 1017).  %% ip 黑名单

-define(GATEWAY_CMD_IS_PLAYING_GAME, 1019).  %% 用户是否在游戏中
-define(GATEWAY_CMD_IS_PLAYING_GAME_REPLY, 1020).  %% 用户是否在游戏中



-endif.