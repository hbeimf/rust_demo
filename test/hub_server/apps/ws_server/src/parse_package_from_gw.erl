% parse_package_from_gw.erl
-module(parse_package_from_gw).
-compile(export_all).



-include("log.hrl").
-include("cmd_gateway.hrl").
-include("gateway_proto.hrl").

parse_package(Bin, State) ->
	case glib:unpackage(Bin) of
		{ok, waitmore}  -> {ok, waitmore, Bin};
		{ok,{Cmd, ValueBin},LefBin} ->
			action(Cmd, ValueBin, State),
			parse_package(LefBin, State);
		_ ->
			error		
	end.


% 用户是否在游戏中回复 
action(?GATEWAY_CMD_IS_PLAYING_GAME_REPLY, Package, _State) -> 
	{isPlayingGameRes, Uid, SeqID, FromGs, IsPlayingGame} =  binary_to_term(Package),
	gs_call:isPlayingGameRes(Uid, SeqID, FromGs, IsPlayingGame),
	ok;

%%　gateway 注册自己
%% 此时要返回所有已上报的游戏节点
action(?GATEWAY_CMD_REPORT, Package, _State) -> 
	?LOG({?GATEWAY_CMD_REPORT, Package}),
	#'Gateway'{gateway_id = GatewayId, ws_addr = GatewayUri} = gateway_proto:decode_msg(Package,'Gateway'),
	?LOG({GatewayId, GatewayUri}),
	table_gateway_list:add(GatewayId, GatewayUri, self()),

	%%
	self() ! {gw_report, GatewayId, GatewayUri},

	%% 返回所有已上报的游戏节点
	case table_game_server_list:select() of 
		[] -> 
			ok;
		GameServerList ->
			lists:foreach(fun(GameServer) -> 
				ServerID = table_game_server_list:get_client(GameServer, server_id),
				ServerType = table_game_server_list:get_client(GameServer, server_type),
				ServerURI = table_game_server_list:get_client(GameServer, server_uri),
				Max = table_game_server_list:get_client(GameServer, max),
				self() ! {gs_report, ServerID, ServerType, ServerURI, Max}
			end, GameServerList)
	end,
	ok;

% 上线
action(?GATEWAY_CMD_SEND_CLIENT_LOGIN, Package, _State) -> 
	?LOG1({client_login, ?GATEWAY_CMD_SEND_CLIENT_LOGIN}),
	#'ClientLoginReq'{uid = Uid, server_type = ServerType, server_id = ServerId, gateway_id = GatewayId} = gateway_proto:decode_msg(Package,'ClientLoginReq'),
	?LOG1({gateway_id, GatewayId}),
	% 人数统计
	case table_client_list:select(Uid) of 
		[] ->
			?LOG1({client_login, ?GATEWAY_CMD_SEND_CLIENT_LOGIN}),
			% login 
			table_client_counter:incr({ServerType, ServerId}),
			table_client_counter:incr({server_type, ServerType}),
			table_client_counter:incr({server_id, ServerId}),
			ok;
		[Client|_] ->
			%  换服数据同步
			ServerTypeOld = table_client_list:get_client(Client, server_type),
			ServerIdOld = table_client_list:get_client(Client, server_id),
			GatewayIdOld = table_client_list:get_client(Client, gateway_id),

			?LOG1({client_login, GatewayId, GatewayIdOld}),
			case GatewayId =:= GatewayIdOld of 
				true ->
					?LOG1({client_login, GatewayId, GatewayIdOld}),
					ok;
				_ ->
					%% 当上报的数据来自不同的网关时，说明同一个用户在多个地方登录了，
					?LOG1({login_other_place, Uid, GatewayIdOld}),
					gw_call:send_user_login_other_place(Uid, GatewayIdOld),
					ok
			end,

			table_client_counter:decr({ServerTypeOld, ServerIdOld}),
			table_client_counter:decr({server_type, ServerTypeOld}),
			table_client_counter:decr({server_id, ServerIdOld}),

			table_client_counter:incr({ServerType, ServerId}),
			table_client_counter:incr({server_type, ServerType}),
			table_client_counter:incr({server_id, ServerId})
	end,

	table_client_list:add(Uid, ServerType, ServerId, GatewayId),
	ok;
% 下线
action(?GATEWAY_CMD_SEND_CLIENT_LOGOUT, Package, _State) -> 
	#'ClientLogoutReq'{uid = Uid, serverID = ServerId} = gateway_proto:decode_msg(Package,'ClientLogoutReq'),
	gs_call:client_logout(Uid, ServerId),
	
	case table_client_list:select(Uid) of 
		[] ->
			ok;
		[Client|_] ->
			% 人数统计 -1
			ServerType = table_client_list:get_client(Client, server_type),
			ServerId = table_client_list:get_client(Client, server_id),

			table_client_counter:decr({ServerType, ServerId}),
			table_client_counter:decr({server_type, ServerType}),
			table_client_counter:decr({server_id, ServerId})
	end,

	table_client_list:delete(Uid),
	
	ok;

action(_Cmd, _Package, _State) -> 
	?LOG(<<"ignore packge">>),
	ok.
