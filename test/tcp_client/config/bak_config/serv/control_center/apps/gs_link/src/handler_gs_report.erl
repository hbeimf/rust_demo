% gs_report.erl
-module(handler_gs_report).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-include_lib("ws_server/include/log.hrl").
% -include("gw_proto.hrl").
-include_lib("gs_link/include/gwc_proto.hrl").


%% 游戏服上报 http api
% http://192.168.1.188:7788/report?proto=CPIHEioKBDEwMDESATEaHXdzOi8vbG9jYWxob3N0Ojc3ODgvd2Vic29ja2V0IAwaATA=
% http://192.168.1.188:7788/report?ReportServerInfo={base64}
% http://192.168.1.188:7788/report?ReportServerInfo=CgQxMDAxEgExGh13czovL2xvY2FsaG9zdDo3Nzg4L3dlYnNvY2tldCgM


init(_Transport, Req, []) ->
	{ok, Req, undefined}.

handle(Req, State) ->
	{Method, Req2} = cowboy_req:method(Req),
	{Proto, Req3} = cowboy_req:qs_val(<<"ReportServerInfo">>, Req2),
	?LOG({proto, Proto}),
	{ok, Req4} = reply(Method, Proto, Req3),
	{ok, Req4, State}.

reply(<<"GET">>, undefined, Req) ->
	cowboy_req:reply(400, [], <<"Missing ReportServerInfo parameter.">>, Req);
reply(<<"GET">>, Proto, Req) ->
	try
		ReportServerInfo = base64:decode(Proto),
		
		#'ReportServerInfo'{serverType = ServerType, 
						serverID = ServerID, 
						serverURI= ServerURI,
						gwcURI = GwcURI,
						max = Max} = gwc_proto:decode_msg(ReportServerInfo,'ReportServerInfo'),

		?LOG({report, ServerType, ServerID, ServerURI, Max}),

		%% 检查serverId 是否被使用过了，如果已经被使用，则提示上报失败
		case table_game_server_list:select(ServerID) of
			[] ->

				table_game_server_list:add(ServerID, ServerType, ServerURI, GwcURI, Max),

				% case table_gateway_list:select() of
				% 	[] -> ok;
				% 	[FirstGateway|_] ->
				% 		GPid = table_gateway_list:get_client(FirstGateway, pid),
				% 		GPid ! {gs_report, ServerID, ServerType, ServerURI, Max}
				% end,

				Gws = table_gateway_list:select(),
				gs_report_to_gw(Gws, {gs_report, ServerID, ServerType, ServerURI, Max}),

				%% 建立与游戏服tcp连接
				gs_call:report(ServerID, ServerType, ServerURI, GwcURI, Max),

				cowboy_req:reply(200, [
					{<<"content-type">>, <<"text/plain; charset=utf-8">>}
				], <<"ok">>, Req);
			_ ->
				cowboy_req:reply(200, [
					{<<"content-type">>, <<"text/plain; charset=utf-8">>}
				], <<"error: serverID already used">>, Req)
		end
	catch _:_ ->
		?LOG(<<"proto decode error">>),
		cowboy_req:reply(200, [
					{<<"content-type">>, <<"text/plain; charset=utf-8">>}
				], <<"error">>, Req)
	end;
reply(_, _, Req) ->
	%% Method not allowed.
	cowboy_req:reply(405, Req).

terminate(_Reason, _Req, _State) ->
	ok.

% http://192.168.1.188:7788/report?proto=CPIHEioKBDEwMDESATEaHXdzOi8vbG9jYWxob3N0Ojc3ODgvd2Vic29ja2V0IAwaATA=

% priv 
%%　上报游戏服到网关
gs_report_to_gw([], _) ->
	ok;
gs_report_to_gw([Gw|OtherGw], ReportGs) ->
	GPid = table_gateway_list:get_client(Gw, pid),
	% GPid ! {gs_report, ServerID, ServerType, ServerURI, Max},
	GPid ! ReportGs,
	gs_report_to_gw(OtherGw, ReportGs).



