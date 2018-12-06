% gs.erl
-module(gs_call).
-compile(export_all).

-include_lib("ws_server/include/log.hrl").
-include("gwc_proto.hrl").
-include("cmd_gs.hrl").


% 用户是否在游戏中回复
% message isPlayingGameRes { //cmd=14
%                            int32 isPlaying = 1;
%                            string seqID = 2; //请求序列ID
% }
% 在游戏中
isPlayingGameRes(Uid, SeqID, FromGs, true) ->
	?LOG1({reply_to_gs, Uid, SeqID, FromGs, true}),
	IsPlayingGameRes = #'isPlayingGameRes'{
                        isPlaying = 1,
                        seqID = SeqID
                    },
    IsPlayingGameResBin = gwc_proto:encode_msg(IsPlayingGameRes),
    Package = glib:package(?CMD_GS_13_REPLY, IsPlayingGameResBin),
	FromGs ! {send, Package},
	ok;
% 不在游戏中
isPlayingGameRes(Uid, SeqID, FromGs, _) ->
	?LOG1({reply_to_gs, Uid, SeqID, FromGs, false}),
	IsPlayingGameRes = #'isPlayingGameRes'{
                        isPlaying = 0,
                        seqID = SeqID
                    },
    IsPlayingGameResBin = gwc_proto:encode_msg(IsPlayingGameRes),
    Package = glib:package(?CMD_GS_13_REPLY, IsPlayingGameResBin),
	FromGs ! {send, Package},
	ok.

% gs_call:get_ip_port().
get_ip_port() ->
	get_ip_port("127.0.0.1:8899").
get_ip_port(GwcURI) -> 
	?LOG({glib:to_str(GwcURI)}),
	[Ip, Port|_] = glib:explode(glib:to_str(GwcURI), ":"),
	?LOG({Ip, Port}),
	{Ip, glib:to_integer(Port)}.


report(ServerID, ServerType, ServerURI, GwcURI, Max) ->
	?LOG({report, ServerID, ServerType, ServerURI, GwcURI, Max}),

	%% 防止重复上报逻辑, 

	% 
	
	case handler_gs_tcp:start_link(ServerID, ServerType, ServerURI, GwcURI, Max) of 
		{ok, Pid} -> 
			?LOG({connect_2_gs_success}),
			table_game_server_list:update(ServerID, pid_to_gs, Pid),
			ok;
		_ -> 
			?LOG({connect_2_gs_failed}),
			ok
	end,
	ok.

% report(ServerID, ServerType, ServerURI, GwcURI, Max) ->
% 	?LOG({report, ServerID, ServerType, ServerURI, GwcURI, Max}),

% 	%% 防止重复上报逻辑, 

% 	% 
% 	case handler_gs_wsc:start_link(ServerID, ServerType, ServerURI, GwcURI, Max) of 
% 		{ok, Pid} -> 
% 			?LOG({connect_2_gs_success}),
% 			table_game_server_list:update(ServerID, pid_to_gs, Pid),
% 			ok;
% 		_ -> 
% 			?LOG({connect_2_gs_failed}),
% 			ok
% 	end,
% 	ok.


client_logout(Uid, ServerID) ->
	?LOG({logout, Uid, ServerID}),
	case table_game_server_list:select(ServerID) of
		[] ->
			ok;
		[GameServer|_] ->
			Pid = table_game_server_list:get_client(GameServer, pid_to_gs),
			send_uid_logout(Uid, Pid)
	end,
	ok.



% message NotifyClose{        //心跳 cmd=5 uid断开连接，网关通知游戏服
%     string uid = 1;
% }
send_uid_logout(Uid, Pid) ->
	?LOG({Uid, Pid}),
	case erlang:is_pid(Pid) andalso glib:is_pid_alive(Pid) of
		true -> 
			%% send pack
			?LOG({send_package, Uid, Pid}),
			NotifyClose = #'NotifyClose'{
                        uid = Uid 
                    },
		    NotifyCloseBin = gwc_proto:encode_msg(NotifyClose),
		    Package = glib:package(?CMD_GS_5, NotifyCloseBin),
		    Pid ! {send, Package},
			ok;
		_ ->
			ok
	end,
	ok.


% priv

% 发送包到游戏服
send_package_to_gs([], _Package) ->
	ok;
send_package_to_gs([GameServer|OtherGameServer], Package) ->
	Pid = table_game_server_list:get_client(GameServer, pid_to_gs),
	Pid ! {send, Package},
	send_package_to_gs(OtherGameServer, Package).



% message ReportServerInfo{  //上报服务器信息 http
%     string serverType = 1; //服务器类型
% //  serverType：
% //    0000 控制节点， 如果选择换服到0000类型的节点，就回复 CommonStatus
% //    100 账号中心（ws）
% //    1000 大厅    （ws）
% //    1001 3D捕鱼     (ws)
% //    1002 百人二八杠  (ws)
% //    1003 压庄龙虎    (ws)
% //    1004 扎金花      (ws)
% //    1005 通比牌九     (ws)
% //    1006 抢庄牛牛     (ws)
% //    1007 红黑大战     (ws)
% //    1008 十三水       (ws)
% //    1009 斗地主       (ws)
% //    1010 德州扑克     (ws)
% //    1011 百家乐       (ws)
% //    1012 三公         (ws)
% //    1013 跑得快        (ws)
% //    1014 极速扎金花     (ws)
% //    1015 21点          (ws)

%     string serverID = 2;    //服务器ID  自行分配

%     string serverURI = 3;   //提供服务的内网地址 ws://192.168.1.1:8000
%     string gwcURI = 4;   //提供控制节点的内网地址 ws://192.168.1.1:8001
%     int32 max = 5;        //最大承载用户数
% }
% http://192.168.1.188:7788/report?ReportServerInfo=CgQxMDAwEgEyGh13czovL2xvY2FsaG9zdDo3Nzg4L3dlYnNvY2tldCIdd3M6Ly9sb2NhbGhvc3Q6Nzc4OC93ZWJzb2NrZXQo6Ac=

link() ->
	

	ReportServerInfo = #'ReportServerInfo'{
                        serverType = <<"1000">>,
                        serverID = <<"2">>,
                        serverURI = <<"ws://localhost:7788/websocket">>,
                        gwcURI = <<"ws://localhost:7788/websocket">>,
                        max = 1000

                    },
    GetEntranceReqBin = gwc_proto:encode_msg(ReportServerInfo),

    Link = "http://192.168.1.188:7788/report?ReportServerInfo=" ++ base64:encode_to_string(GetEntranceReqBin),

    ?LOG({link, Link}),
	ok.