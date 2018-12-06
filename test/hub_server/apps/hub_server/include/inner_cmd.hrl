-ifndef(INNER_CMD).
-define(INNER_CMD,true).

%% 协议号定义
-define(INNER_CMD_REGIST_PROXY, 101).  %% 注册 proxy_server
-define(INNER_CMD_LOGIN, 103). %% 登录 
-define(INNER_CMD_LOGIN_REPLY, 104). %% 登录回复  
-define(INNER_CMD_LOGOUT, 105). %% 退出登录  
-define(INNER_CMD_SYNC_CLIENTS, 106). %% 同步客户信息到hub   

-endif.