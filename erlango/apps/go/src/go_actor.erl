-module(go_actor).

-behaviour(gen_server).
% --------------------------------------------------------------------
% Include files
% --------------------------------------------------------------------
% -include("log.hrl").
% -include("msg_proto.hrl").

% -record(state, { 
% 	socket,
% 	transport,
% 	ip,
% 	port,
% 	data,
% 	call_pid
% }).

-define(TIMER_SECONDS, 30000).  % 
-define(TIMEOUT, 1000).

% --------------------------------------------------------------------
% External exports
% --------------------------------------------------------------------
-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

% --------------------------------------------------------------------
% External API
% --------------------------------------------------------------------
% -export([send/0, send/1, call_req/2]).
% -export([call_req/2]).

% call_req(Pid, Package) ->
% 	gen_server:call(Pid, {call, Package}, ?TIMEOUT).

% start_link(ServerID, ServerType, ServerURI, GwcURI, Max) ->
% 	?LOG({ServerID, ServerType, ServerURI, GwcURI, Max}),
%     gen_server:start_link({local, ?MODULE}, ?MODULE, [ServerID, ServerType, ServerURI, GwcURI, Max], []).


start_link(Params) ->
	gen_server:start_link(?MODULE, [Params], []).


% --------------------------------------------------------------------
% Function: init/1
% Description: Initiates the server
% Returns: {ok, gs_tcp_state}          |
%          {ok, gs_tcp_state, Timeout} |
%          ignore               |
%          {stop, Reason}
% --------------------------------------------------------------------
init([_Params]) ->
	erlang:send_after(?TIMEOUT, self(), check_state), %
	
    % {ok, Pid} = go_ws_actor:start_link(1),

    % {ok, #{ws_pid => Pid}}.
	{ok, #{ws_pid => false}}.
% --------------------------------------------------------------------
% Function: handle_call/3
% Description: Handling call messages
% Returns: {reply, Reply, gs_tcp_state}          |
%          {reply, Reply, gs_tcp_state, Timeout} |
%          {noreply, gs_tcp_state}               |
%          {noreply, gs_tcp_state, Timeout}      |
%          {stop, Reason, Reply, gs_tcp_state}   | (terminate/2 is called)
%          {stop, Reason, gs_tcp_state}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_call(_Request, _From, State) ->
	Reply = ok,
	{reply, Reply, State}.

% --------------------------------------------------------------------
% Function: handle_cast/2
% Description: Handling cast messages
% Returns: {noreply, gs_tcp_state}          |
%          {noreply, gs_tcp_state, Timeout} |
%          {stop, Reason, gs_tcp_state}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_cast({send, FromPid, Cmd, ReqPayload}, #{ws_pid := Pid} = State) ->
	Key = base64:encode(term_to_binary({FromPid, self()})),
	Package = glib_pb:encode_RpcPackage(Key, Cmd, ReqPayload),
	Pid ! {send, Package},
	{noreply, State};
handle_cast(_Msg, State) ->
	{noreply, State}.		

% --------------------------------------------------------------------
% Function: handle_info/2
% Description: Handling all non call/cast messages
% Returns: {noreply, gs_tcp_state}          |
%          {noreply, gs_tcp_state, Timeout} |
%          {stop, Reason, gs_tcp_state}            (terminate/2 is called)
% --------------------------------------------------------------------
% erlang:send_after(?TIMEOUT, self(), check_state), %
handle_info(check_state, #{ws_pid := Pid} = State) -> 
	% ?LOG({info, Info}),
	% {stop, normal, gs_tcp_state}.
	erlang:send_after(?TIMEOUT, self(), check_state), %
	case erlang:is_pid(Pid) andalso glib:is_pid_alive(Pid) of
		true -> 
			{noreply, State};
		_ -> 
			case go_ws_actor:start_link(1) of 
				{ok, NewPid} -> 
					{noreply, #{ws_pid => NewPid}};
				_ -> 
					{noreply, State}
			end
	end;
handle_info(_Info, State) ->  
	% ?LOG({info, Info}),
	% {stop, normal, gs_tcp_state}.
	{noreply, State}.


% --------------------------------------------------------------------
% Function: terminate/2
% Description: Shutdown the server
% Returns: any (ignored by gen_server)
% --------------------------------------------------------------------
terminate(_Reason, _State) ->
	% ?LOG(closed),
	ok.

% --------------------------------------------------------------------
% Func: code_change/3
% Purpose: Convert process gs_tcp_state when code is changed
% Returns: {ok, Newgs_tcp_state}
% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
	{ok, State}.


% priv






