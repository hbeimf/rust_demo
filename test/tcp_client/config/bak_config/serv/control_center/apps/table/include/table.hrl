%% 定义记录结构


-record(gateway_list, {
	gateway_id=0, %%  网关id
	gateway_uri="", %%   网关 ws地址
	pid=0 %%  
}).


% message ServerInfo{
%     string serverType = 1; //服务器类型
%     string serverID = 2;    //服务器ID
%     string serverURI = 3;   //内网地址 ws://://192.168.1.1:8000   h      http://192.168.1.1:8000/interface
   
%     int max = 4;        //最大承载用户数
% }

-record(game_server_list, {
	server_id=0, %%  游戏服id
	server_type=0, %%  游戏服类型
	server_uri="",  %%  客户端连游戏服地址
	gwc_uri="", %% gwc连接游戏服地址
	max=0, %%   游戏服最多能容纳多少链接 
	pid_to_gs=0  %%　
}).


-record(client_list, {
	uid=0, %%  客户端  uid
	server_type="",
	server_id = "",
	gateway_id=0, %%  网关id
	cache_bin = ""  %% 缓存二进制数据
}).


%% 在线人数统计 
-record(client_counter, {
	key, 
	counter
}).



%% 被禁用 ip 
-record(forbidden_ip, {
	name,
	ip
}).
