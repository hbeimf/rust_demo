% -record(state, {
% 	socket, 
% 	transport, 
% 	data,
% 	ip,
% 	port}).

-record(gs_tcp_state, { 
	server_id=0, %%  游戏服id
	server_type=0, %%  游戏服类型
	server_uri="",  %%  客户端连游戏服地址
	gwc_uri="", %% gwc连接游戏服地址
	max=0, %%   游戏服最多能容纳多少链接 
	socket,
	transport,
	ip,
	port,
    data
    }).

