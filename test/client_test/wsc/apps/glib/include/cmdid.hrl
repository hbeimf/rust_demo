-ifndef(CMD_ID).
-define(CMD_ID,true).

% -define(GATEWAY_CMD_REPORT, 1001).  %% 网关上报信息到控制中心节点
% -define(GATEWAY_CMD_GS_REPORT, 1002).  %% 游戏服

-define(CMD_ID_1, 1).  %% 请求获取入口 cmd=1 客户端发起请求
-define(CMD_ID_1_REPLY, 2).  %% 

-define(CMD_ID_3, 3).  %% 请求认证 cmd=3  http
-define(CMD_ID_3_REPLY, 4).  %% 

-define(CMD_ID_5, 5).  %% 请求进入游戏 此协议由客户端统一调用 cmd=5 客户端发起请求
-define(CMD_ID_5_REPLY, 6).  %% 

-define(CMD_ID_10, 10).  %% message CommonStatus {  //通用信息 cmd=10

-define(CMD_ID_100, 100).  %% cmd = 100透传

-endif.