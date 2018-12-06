-module(tcp_handler).
-behaviour(gen_server).
-behaviour(ranch_protocol).

%% API.
-export([start_link/4]).

%% gen_server.
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).

-define(TIMEOUT, 5000).

% -record(state, {socket, transport, data}).
-include_lib("state.hrl").

% http://blog.csdn.net/yuanfengyun/article/details/49329327
% http://www.cnblogs.com/bicowang/p/4263227.html
%% 宏定义
% -define( PORT, 2345 ).
% -define( HEAD_SIZE, 4 ).
% %% 解数字类型用到的宏
% -define( UINT, 32/unsigned-little-integer).
% -define( INT, 32/signed-little-integer).
% -define( USHORT, 16/unsigned-little-integer).
% -define( SHORT, 16/signed-little-integer).
% -define( UBYTE, 8/unsigned-little-integer).
% -define( BYTE, 8/signed-little-integer).

%% API.

start_link(Ref, Socket, Transport, Opts) ->
	{ok, proc_lib:spawn_link(?MODULE, init, [{Ref, Socket, Transport, Opts}])}.

%% gen_server.

%% This function is never called. We only define it so that
%% we can use the -behaviour(gen_server) attribute.
%init([]) -> {ok, undefined}.

init({Ref, Socket, Transport, _Opts = []}) ->
	ok = ranch:accept_ack(Ref),
	ok = Transport:setopts(Socket, [{active, once}]),
	io:format("~p:~p  ========= tcp connect  !!!!!! ~n~n", [?MODULE, ?LINE]),

	gen_server:enter_loop(?MODULE, [],
		#state{socket=Socket, transport=Transport, data= <<>>},
		?TIMEOUT).

handle_info({tcp, Socket, CurrentPackage}, State=#state{
		socket=Socket, transport=Transport, data=LastPackage}) -> 
		% when byte_size(Data) > 1 ->
	Transport:setopts(Socket, [{active, once}]),
	PackageBin = <<LastPackage/binary, CurrentPackage/binary>>,

	% io:format("package ========== ~p~n ", [PackageBin]),

	% case tcp_package:unpackage(PackageBin) of
	% 	{ok, waitmore} -> 
	% 		% io:format("wait more ===========~n~n"),
	% 		{noreply, State#state{data = PackageBin}};
	% 	{ok, {Type, ValueBin}, NextPageckage} -> 
	% 		tcp_controller:action(Type, ValueBin),
	% 		{noreply, State#state{data = NextPageckage}};			
	% 	_ -> 
	% 		{stop, stop_noreason,State}
	% end;

	case parse_package(PackageBin, State) of
		{ok, waitmore, Bin} -> 
			{noreply, State#state{data = Bin}};
		_ -> 
			{stop, stop_noreason,State}
	end;	

	% Transport:send(Socket, reverse_binary(Data)),
	% {noreply, State, ?TIMEOUT};

handle_info({tcp_send, Package}, #state{transport = Transport,socket=Socket} = State) ->
	% io:format("send data ---------------------------------------"),
	% ok = Transport:send(Socket,Data),
	Transport:send(Socket, Package),
	
	{noreply, State};
handle_info({tcp_closed, _Socket}, State) ->
	io:format("~p:~p  tcp closed  !!!!!! ~n~n", [?MODULE, ?LINE]),
	%% 当代理连接断开时，要清理代理相关的数据
	table_proxy_server_list:delete(self()),
	{stop, normal, State};
handle_info({tcp_error, _, Reason}, State) ->
	{stop, Reason, State};
handle_info(timeout, State) ->
	{stop, normal, State};
handle_info(_Info, State) ->
	{stop, normal, State}.

handle_call(_Request, _From, State) ->
	{reply, ok, State}.

handle_cast(_Msg, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.


%% ====================================================================
%% Internal functions
%% ====================================================================
parse_package(Bin, State) ->
	case tcp_package:unpackage(Bin) of
		{ok, waitmore}  -> {ok, waitmore, Bin};
		{ok,{Type, ValueBin},LefBin} ->
			ctrl_handler:action(Type, ValueBin, State),
			parse_package(LefBin, State);
		_ ->
			error		
	end.

