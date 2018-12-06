-module(ctrl_handler).
%% API.
-export([action/3]).

-include_lib("inner_msg_proto.hrl").
-include_lib("inner_cmd.hrl").
-include_lib("state.hrl").

% 注册代理 
action(?INNER_CMD_REGIST_PROXY, DataBin, #state{transport = _Transport,socket=Socket} = _State) ->
	#'InnerRegistProxy'{id = Id, ip = _Ip, port = Port} = inner_msg_proto:decode_msg(DataBin,'InnerRegistProxy'),
	Ip1  =  case ranch_tcp:peername(Socket) of 
			{ok, {TupleIp, _Port}} ->
			            ListIp = tuple_to_list(TupleIp),
			            ListIp1 = lists:map(fun(X)-> libfun:to_str(X) end, ListIp),
			            IpStr = string:join(ListIp1, "."),
			            libfun:to_binary(IpStr);
			_ -> 
			            <<"">>
		end,
	table_proxy_server_list:add(Id, Ip1, Port, self()),
	ok;

%  客户端登录验证
action(?INNER_CMD_LOGIN, DataBin, #state{transport = _Transport, socket= _Socket} = _State) ->
	#'InnerLogin'{user_id = UserId, token = Token, proxy_id = ProxyId, ip = Ip, login_time = LogTime} = inner_msg_proto:decode_msg(DataBin,'InnerLogin'),
	Hash = "userinfo@"++libfun:to_str(UserId),
             Key = "token",
             case redisc:hget(Hash, Key) of 
		{ok,undefined} -> 
			login_reply(ProxyId, UserId, 1, "token 不存在"),
			error;
		{ok, Token} ->
			case table_client_list:select(UserId) of
				[] ->
					table_client_list:add(UserId, ProxyId, LogTime, Ip, Token), 
					login_reply(ProxyId, UserId, 2, "登录成功"),
					ok;
				ClientList -> 
					login_reply(ProxyId, UserId, 2, "登录成功"),
					let_other_client_logout(ClientList),
					table_client_list:add(UserId, ProxyId, LogTime, Ip, Token), 
					ok
			end, 
			ok;
		_ ->
			login_reply(ProxyId, UserId, 4, "token 检查出错"),
			error
	end,
	ok;

action(?INNER_CMD_LOGOUT, DataBin, #state{transport = _Transport, socket= _Socket} = _State) ->
	#'InnerLogout'{user_id = UserId, token = Token, proxy_id = _ProxyId} = inner_msg_proto:decode_msg(DataBin,'InnerLogout'),
	% io:format("mod:~p, line:~p, cmd:~p, param:~p~n", [?MODULE, ?LINE, ?INNER_CMD_LOGOUT, {UserId, Token, ProxyId}]),
	table_client_list:delete(UserId, Token),
	ok;

action(?INNER_CMD_SYNC_CLIENTS, DataBin, #state{transport = _Transport, socket= _Socket} = _State) ->
	#'InnerSyncClients'{clients = Clients} = inner_msg_proto:decode_msg(DataBin,'InnerSyncClients'),
	io:format("mod:~p, line:~p, cmd:~p, param:~p~n", [?MODULE, ?LINE, ?INNER_CMD_LOGOUT, Clients]),
	% table_client_list:delete(UserId, Token),
	lists:foreach(fun(#'InnerLogin'{user_id = UserId, token = Token, proxy_id = ProxyId, ip = Ip, login_time = LogTime}) -> 
		table_client_list:add(UserId, ProxyId, LogTime, Ip, Token), 
		ok
	end, Clients),
	ok;


% 未匹配的消息直接忽略
action(_Type, _DataBin, _State) ->
	% P = tcp_package:package(Type+1, DataBin),
	% self() ! {tcp_send, P},
	% io:format("~n ================================= ~ntype:~p, bin: ~p ~n ", [Type, DataBin]). 
	ok.


% =============================================================
% private function ================================================
% =============================================================

login_reply(ProxyId, UserId, ErrorType, Msg) -> 
	% Msg = unicode:characters_to_list("token 检查出错 "),
	InnerLoginReply = #'InnerLoginReply'{user_id = UserId, error_type = ErrorType, msg = unicode:characters_to_list(Msg)},
	Bin = inner_msg_proto:encode_msg(InnerLoginReply),
	PackageLoginReply = tcp_package:package(?INNER_CMD_LOGIN_REPLY, Bin),
	send_binary_by_proxyid(ProxyId, PackageLoginReply),
	ok.

% 给代理发送消息
send_binary_by_proxyid(ProxyId, PackageLoginReply) -> 
	case table_proxy_server_list:select(ProxyId) of
		[] -> 
			ok;
		[Proxy|_] ->
			ProxyPid = table_proxy_server_list:get_proxy_pid(Proxy),
			ProxyPid ! {tcp_send, PackageLoginReply},
			ok
	end,
	ok.

% 通知别的客户端，账号已在别的位置登录 
let_other_client_logout(_) -> 
	ok.

% let_other_client_logout([]) ->
% 	ok;
% let_other_client_logout(ClientList) ->
% 	% io:format("mod:~p, line:~p, param:~p~n", [?MODULE, ?LINE, ClientList]),
% 	lists:foreach(fun(Client) -> 
% 		ProxyId = table_client_list:get_client(Client, proxy_id),
% 		UserId = table_client_list:get_client(Client, userid),
% 		login_reply(ProxyId, UserId, 3, "客户在其它地方登录了！"),
% 		ok
% 	end, ClientList),
% 	ok.


