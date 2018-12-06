% gw_call.erl
-module(gw_call).
-compile(export_all).
-include("log.hrl").
-include("cmd_gateway.hrl").
-include("gateway_proto.hrl").


%% ip 黑名单
% gw_call:send_forbidden_ip(add, Ip).
send_forbidden_ip(add, Ip) ->
    ?LOG({add, Ip}),
    PackageBin = glib:package(?GATEWAY_CMD_FORBIDDEN_IP, term_to_binary({add, Ip})),
    send_package_to_gw(PackageBin),
    ok;
send_forbidden_ip(del, Ip) ->
    ?LOG({del, Ip}),
    PackageBin = glib:package(?GATEWAY_CMD_FORBIDDEN_IP, term_to_binary({del, Ip})),
    send_package_to_gw(PackageBin),
    ok.


%% 游戏服挂了， 通知网关，
send_gs_halt_msg(ServerID, ServerType) ->
	?LOG({ServerID, ServerType}),
	GsHalt = #'GsHalt'{
                        serverType = ServerType,
                        serverID = ServerID
                    },
    GsHaltBin = gateway_proto:encode_msg(GsHalt),

    Package = glib:package(?GATEWAY_CMD_GS_HALT, GsHaltBin),

 %    case table_gateway_list:select() of
	% 	[] -> ok;
	% 	[FirstGateway|_] ->
	% 		GPid = table_gateway_list:get_client(FirstGateway, pid),
	% 		GPid ! {send, Package}
	% end,

    send_package_to_gw(Package),
	ok.


% gw_call:send_to_gw_broadcast1().
%%　广播　
send_to_gw_broadcast1(Package) ->
	?LOG({broadcast1, Package}),
    Package1 = glib:package(?GATEWAY_CMD_BROADCAST_1, Package),
    send_package_to_gw(Package1),
	ok.

%%　广播　
send_to_gw_broadcast2(Package) ->
	?LOG({broadcast2, Package}),
    Package1 = glib:package(?GATEWAY_CMD_BROADCAST_2, Package),
    send_package_to_gw(Package1),
	ok.



% 踢人
send_to_gw_tick_user(Package) ->
	 ?LOG({tick_user, Package}),
    Package1 = glib:package(?GATEWAY_CMD_TICK_USER, Package),
    send_package_to_gw(Package1),
    ok.

%% 用户在其它地方登录
send_user_login_other_place(Uid, GatewayId) ->
    ?LOG1({login_other_place, Uid, GatewayId}),

    UserLoginOtherPlace = #'UserLoginOtherPlace'{
                        uid = Uid
                    },
    UserLoginOtherPlaceBin = gateway_proto:encode_msg(UserLoginOtherPlace),

    Package = glib:package(?GATEWAY_CMD_USER_LOGIN_OTHER_PLACE, UserLoginOtherPlaceBin),

    send_package_to_gw_by_gateway_id(Package, GatewayId),

    ok.


%% 查看用户是否在游戏中
% gw_call:isPlayingGameReq(Clients, PackageBin).
isPlayingGameReq([], _DataBin) ->
    ok;
isPlayingGameReq([Client|OtherClient], DataBin) ->
    GatewayId = table_client_list:get_client(Client, gateway_id),
    PackageBin = glib:package(?GATEWAY_CMD_IS_PLAYING_GAME, DataBin),
    send_package_to_gw_by_gateway_id(PackageBin, GatewayId),
    isPlayingGameReq(OtherClient, DataBin).

%% priv
send_package_to_gw_by_gateway_id(PackageBin, GatewayId) ->
    ?LOG1({send_by_gw_id, PackageBin, GatewayId}),
    GwList = table_gateway_list:select(glib:to_integer(GatewayId)),
    ?LOG1({send_by_gw_id, GwList}),
    send_package_to_gw(PackageBin, GwList),
    ok.
    
% table_gateway_list:select(<<"1">>).


%% 发送包给gw
send_package_to_gw(PackageBin) -> 
    % case table_gateway_list:select() of
    %     [] -> ok;
    %     [FirstGateway|_] ->
    %         GPid = table_gateway_list:get_client(FirstGateway, pid),
    %         GPid ! {send, PackageBin}
    % end.
    GwList = table_gateway_list:select(),
    send_package_to_gw(PackageBin, GwList).

send_package_to_gw(_PackageBin, []) ->
	ok;
send_package_to_gw(PackageBin, [Gw|OtherGw]) ->
    GPid = table_gateway_list:get_client(Gw, pid),
    ?LOG1({send_to_gw}),
    GPid ! {send, PackageBin},
    send_package_to_gw(PackageBin, OtherGw).



