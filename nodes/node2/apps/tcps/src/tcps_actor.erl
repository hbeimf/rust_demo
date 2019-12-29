-module(tcps_actor).
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

% -define(TIMEOUT, infinity).

% -record(state, {socket, transport, data}).
-include("state.hrl").
-include_lib("glib/include/log.hrl").
-include_lib("glib/include/rr.hrl").

% -include_lib("glib/include/log.hrl").

start_link(Ref, Socket, Transport, Opts) ->
	{ok, proc_lib:spawn_link(?MODULE, init, [{Ref, Socket, Transport, Opts}])}.

%% gen_server.

%% This function is never called. We only define it so that
%% we can use the -behaviour(gen_server) attribute.
%init([]) -> {ok, undefined}.

init({Ref, Socket, Transport, _Opts = []}) ->
	ok = ranch:accept_ack(Ref),
	ok = Transport:setopts(Socket, [{active, once}]),

	gen_server:enter_loop(?MODULE, [],
		#state{socket=Socket, transport=Transport, data= <<>>},
		?TIMEOUT).

handle_info({tcp, Socket, CurrentPackage}, State=#state{
		socket=Socket, transport=Transport, data=LastPackage}) -> 
		% when byte_size(Data) > 1 ->
	Transport:setopts(Socket, [{active, once}]),
	PackageBin = <<LastPackage/binary, CurrentPackage/binary>>,

	case parse_package(PackageBin, State) of
		{ok, waitmore, Bin} -> 
			{noreply, State#state{data = Bin}};
		_ -> 
			{stop, normal,State}
	end;	

handle_info({send, Package}, #state{transport = Transport,socket=Socket} = State) ->
	% ?LOG({send, Package}),
	Transport:send(Socket, Package),
	{noreply, State};
handle_info({tcp_closed, _Socket}, State) ->
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
	% case tcp_package:unpackage(Bin) of
	case glib:unpackage(Bin) of
		{ok, waitmore}  -> {ok, waitmore, Bin};
		{ok,{_Cmd, ValueBin},LefBin} ->
			tcps_action:action(ValueBin),
			% ?LOG({Type, ValueBin}),
			parse_package(LefBin, State);
		_ ->
			error		
	end.

% try_action(Cmd, ValueBin, _State) -> 
%     ?LOG({Cmd, ValueBin, binary_to_term(ValueBin)}),
%     % ?LOG(ValueBin),
%     % R = binary_to_term(ValueBin),
%     % % Req = binary_to_term(ValueBin),
%     % ?LOG(R),
%     % action(ValueBin),
%     % wss_action:action(ValueBin),
% 	ok.

% action(Package) -> 
%     #request{from = From, req_cmd = Cmd, req_data = ReqPackage} = binary_to_term(Package),
    
%     ok.


% % -record(reply, {
% % 	from, 
% %     reply_code,
% %     reply_data
% % }).
% action(1000, _, From) ->
%     % Reply = term_to_binary(#reply{from = From, reply_code = 1001, reply_data = pong}),
%     % self() ! {send, Reply},
%     ?LOG(pong),
%     ok;
% action(Cmd, ReqPackage, From) ->
%     ?LOG({Cmd, ReqPackage, From}),
%     ok.