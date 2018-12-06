-module(parse_package_from_gs).
-compile(export_all).

% -include("gateway_proto.hrl").
% -include("cmd_gateway.hrl").
-include_lib("ws_server/include/log.hrl").
-include("gs_wsc_state.hrl").
-include("cmd_gs.hrl").
-include("gwc_proto.hrl").

-include_lib("ws_server/include/cmd_gateway.hrl").


parse_package(Bin, State) ->
    ?LOG({bin, Bin}),
    case glib:unpackage(Bin) of
        {ok, waitmore}  -> {ok, waitmore, Bin};
        {ok,{Cmd, ValueBin},LefBin} ->
            action(Cmd, ValueBin, State),
            parse_package(LefBin, State);
        _ ->
            error       
    end.



% action(?GATEWAY_CMD_GS_REPORT, Package, _State) -> 
%     ?LOG({?GATEWAY_CMD_GS_REPORT, Package}),
%     #'ReportServerInfo'{serverType = ServerType, 
%                         serverID = ServerID,
%                         serverURI = ServerURI, 
%                         max = Max} = gateway_proto:decode_msg(Package,'ReportServerInfo'),
%     ?LOG({ServerType, ServerID, ServerURI, Max}),
%     table_game_server_list:add(ServerID, ServerType, ServerURI, Max),
%     ok;


% message BroadcastByUID{    //请求认证 Cmd=1
%     repeated Uids uids = 1; //用户身份
%     bytes  payload = 2;     //透传消息体
% }

% message Uids {
%  string uid = 1; //
% }

% message Broadcast{    //请求认证 Cmd=2
%     string serverType = 1; //服务器类型
%     string serverID = 2;    //服务器ID  自行分配
%     bytes  payload = 3; //透传消息体
% }


action(?CMD_GS_1, Package, _State) -> 
    ?LOG({broadcast1, Package}),
    % Package1 = glib:package(?GATEWAY_CMD_BROADCAST_1, Package),
    % send_package_to_gw(Package1),
    gw_call:send_to_gw_broadcast1(Package),
    ok;
action(?CMD_GS_2, Package, _State) -> 
    ?LOG({broadcast2, Package}),
    % Package1 = glib:package(?GATEWAY_CMD_BROADCAST_2, Package),
    % send_package_to_gw(Package1),
    gw_call:send_to_gw_broadcast2(Package),
    ok;

action(?CMD_GS_6, Package, _State) -> 
    ?LOG({tick_user, Package}),
    % Package1 = glib:package(?GATEWAY_CMD_TICK_USER, Package),
    % send_package_to_gw(Package1),
    gw_call:send_to_gw_tick_user(Package),
    ok;


% message getOnlineUserNumReq { //获取在线用户数 cmd=7
%                               string serverType = 1; //服务器类型   当 serverType 和 serverID全部为空的时候，返回全服在线用户数
%                               string serverID = 2; //服务器ID  自行分配
%                               string seqID = 3; //请求序列ID
% }

% message getOnlineUserNumRes { //获取在线用户数 cmd=8
%                               int32 num = 1;
%                               string serverType = 2; //服务器类型   当 serverType 和 serverID全部为空的时候，返回全服在线用户数
%                               string serverID = 3; //服务器ID  自行分配
%                               string seqID = 4; //请求序列ID

% }
action(?CMD_GS_7, Package, _State) -> 
    ?LOG({getOnlineUserNumReq, Package}),
    #'getOnlineUserNumReq'{serverType = ServerType, serverID = ServerId, seqID = SeqId} = gwc_proto:decode_msg(Package,'getOnlineUserNumReq'),
    ?LOG({?CMD_GS_7, ServerType, ServerId, SeqId}),
    OnlineUserNum = table_client_counter:select_counter(ServerType, ServerId),

    GetOnlineUserNumRes = #'getOnlineUserNumRes'{num = OnlineUserNum, serverType = ServerType, serverID = ServerId, seqID = SeqId},
    GetOnlineUserNumResBin = gwc_proto:encode_msg(GetOnlineUserNumRes),
    Package1 = glib:package(?CMD_GS_7_REPLY, GetOnlineUserNumResBin),
    self() ! {send, Package1},
    ok;


% message isOnlineReq { //判断用户是否在线请求 cmd=9
%                       string uid = 1;
%                       string seqID = 2; //请求序列ID
% }

% message isOnlineRes { //判断用户是否在线响应 cmd=10
%                       int32 online = 1; //1: online 0:offline
%                       string seqID = 2; //请求序列ID
% }
action(?CMD_GS_9, Package, _State) -> 
    ?LOG({isOnlineReq, Package}),
    #'isOnlineReq'{uid = Uid, seqID = SeqId} = gwc_proto:decode_msg(Package,'isOnlineReq'),
    case table_client_list:select(Uid) of
        [] ->
            %% 不在线
            IsOnlineRes = #'isOnlineRes'{online = 0, seqID = SeqId},
            IsOnlineResBin = gwc_proto:encode_msg(IsOnlineRes),
            Package1 = glib:package(?CMD_GS_9_REPLY, IsOnlineResBin),
            self() ! {send, Package1},
            ok;
        _ -> 
            % 在线
            IsOnlineRes = #'isOnlineRes'{online = 1, seqID = SeqId},
            IsOnlineResBin = gwc_proto:encode_msg(IsOnlineRes),
            Package1 = glib:package(?CMD_GS_9_REPLY, IsOnlineResBin),
            self() ! {send, Package1},
            ok
    end,
    ok;


% message forbiddenIp { //对 ip 进行封禁操作
%                       int32 type = 1; //1: add 添加 封禁ip 2:del 解除封禁ip
%                       string ip = 2; //具体的ip
% }
action(?CMD_GS_11, Package, _State) -> 
    ?LOG({?CMD_GS_11, Package}),
    #'forbiddenIp'{type = Type, ip = Ip} = gwc_proto:decode_msg(Package,'forbiddenIp'),
    ?LOG({Type, Ip}), 
    case Type of 
        1 ->
            table_forbidden_ip:add(Ip),
            gw_call:send_forbidden_ip(add, Ip),
            ok;
        _ -> 
            table_forbidden_ip:delete(Ip),
            gw_call:send_forbidden_ip(del, Ip),
            ok
    end,
    ok;


% message BroadcastToGameServer { // 对游戏服进行广播，当serverType或 serverID为空串时，对所有游戏服进行广播 Cmd=12
%                     string serverType = 1; //服务器类型
%                     string serverID = 2; //服务器ID  自行分配
%                     bytes payload = 3; //广播消息体
% }
action(?CMD_GS_12, Package, _State) -> 
    ?LOG({?CMD_GS_12, Package}),
    #'BroadcastToGameServer'{serverType = ServerType, serverID = ServerID, 
        payload = Payload} = gwc_proto:decode_msg(Package,'BroadcastToGameServer'),
    ?LOG({ServerType, ServerID, Payload}), 
    GameServers = table_game_server_list:select(ServerID, ServerType),
    gs_call:send_package_to_gs(GameServers, Payload),
    ok;


% message isPlayingGameReq { //判断用户是否在游戏中， cmd=13
%                            string uid = 1;
%                            string seqID = 2; //请求序列ID
% }
% message isPlayingGameRes { //cmd=14
%                            int32 isPlaying = 1;
%                            string seqID = 2; //请求序列ID
% }
action(?CMD_GS_13, Package, _State) -> 
    ?LOG1({?CMD_GS_13, Package}),
    #'isPlayingGameReq'{uid = Uid, seqID = SeqID} = gwc_proto:decode_msg(Package,'isPlayingGameReq'),
    ?LOG1({Uid, SeqID}),
    Clients = table_client_list:select(Uid),
    case Clients of 
        [] ->
            %% 如果没查到账号，说明一定不在游戏中，直接回复 
            gs_call:isPlayingGameRes(Uid, SeqID, self(), false),
            ok;
        _ ->
            DataBin = term_to_binary({isPlayingGameReq, Uid, SeqID, self()}),
            gw_call:isPlayingGameReq(Clients, DataBin),
            ok
    end,     
    ok;

action(_Cmd, Package, _State) -> 
    ?LOG({<<"ignore packge">>, Package}),
    ok.

% priv






% send_package_to_gw(PackageBin) -> 
%     case table_gateway_list:select() of
%         [] -> ok;
%         [FirstGateway|_] ->
%             GPid = table_gateway_list:get_client(FirstGateway, pid),
%             GPid ! {send, PackageBin}
%     end.


