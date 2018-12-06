-module(ws_handler_gateway).
-behaviour(cowboy_websocket_handler).

-export([init/3]).
-export([websocket_init/3]).
-export([websocket_handle/3]).
-export([websocket_info/3]).
-export([websocket_terminate/3]).
% -export([select/0, select/1]).


-include("log.hrl").
-include("cmd_gateway.hrl").
-include("gateway_proto.hrl").


% -include_lib("stdlib/include/qlc.hrl").


init({tcp, http}, _Req, _Opts) ->
	{upgrade, protocol, cowboy_websocket}.

websocket_init(_TransportName, Req, _Opts) ->
	% erlang:start_timer(1000, self(), <<"Hello!">>),
	% uid=0,
	% islogin = false,
	% stype =0,
	% sid=0,
	% data
	% State = #state{uid = 0, islogin = false, stype = 0, sid = 0, data= <<>>},
	State = #state_gateway{gateway_id = 0, data= <<>>},
	% State = ok,
	{ok, Req, State}.

% websocket_handle({text, Msg}, Req, {_, Uid} = State) ->
% 	?LOG({Uid, Msg}),
% 	Clients = select(Uid),
% 	?LOG(Clients),
% 	broadcast(Clients, Msg),
% 	{ok, Req, State};
	% {reply, {text, << "That's what she said! ", Msg/binary >>}, Req, State};


websocket_handle({binary, CurrentPackage}, Req, State= #state_gateway{gateway_id = _GateWayId, data= LastPackage}) ->
	?LOG({"binary recv: ", CurrentPackage}),
	PackageBin = <<LastPackage/binary, CurrentPackage/binary>>,
	case parse_package_from_gw:parse_package(PackageBin, State) of 
		{ok, waitmore, Bin} -> 
			{ok, Req, State#state_gateway{data = Bin}};
		_ -> 
			{shutdown, Req, State}
	end;
websocket_handle(Data, Req, State) ->
	?LOG({"ignore date", Data}),
	{ok, Req, State}.

websocket_info({gs_report, ServerID, ServerType, ServerURI, Max}, Req, State) ->
	?LOG({gs_report, ServerID, ServerType, ServerURI, Max}),
	ReportServerInfo = #'ReportServerInfo'{
                        serverType = ServerType,
                        serverID = ServerID,
                        serverURI = ServerURI,
                        max = Max
                    },
    ?LOG({ReportServerInfo}),
    ReportServerInfoBin = gateway_proto:encode_msg(ReportServerInfo),
    PackageGsReport = glib:package(?GATEWAY_CMD_GS_REPORT, ReportServerInfoBin),
    ?LOG({package, PackageGsReport}),
	{reply, {binary, PackageGsReport}, Req, State};
websocket_info({send, PackageBin}, Req, State) ->
	?LOG({send, PackageBin}),
	{reply, {binary, PackageBin}, Req, State};

%% 网关上报后更新状态
websocket_info({gw_report, GatewayId, _GatewayUri}, Req, State) ->
	{ok, Req, State#state_gateway{gateway_id = GatewayId}};
websocket_info({timeout, _Ref, Msg}, Req, State) ->
	% erlang:start_timer(1000, self(), <<"How' you doin'?">>),
	{reply, {text, Msg}, Req, State};
websocket_info(_Info, Req, State) ->
	{ok, Req, State}.

websocket_terminate(_Reason, _Req, _State = #state_gateway{gateway_id = GateWayId}) ->
	?LOG({gw_closed, GateWayId}),
	table_gateway_list:delete(GateWayId),
	ok.
