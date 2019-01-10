% demo_send.erl
% rabbit_send.erl
%% gen_server代码模板

-module(demo_send).

-behaviour(gen_server).
% --------------------------------------------------------------------
% Include files
% --------------------------------------------------------------------

% --------------------------------------------------------------------
% External exports
% --------------------------------------------------------------------
-export([]).

% gen_server callbacks
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).


-record(state, { 
	channel
    }).

-export([send/0, send/1]).

-include_lib("amqp_client/include/amqp_client.hrl").
-include_lib("glib/include/log.hrl").

send() -> 
	Message = <<"info: Hello World!">>,
	send(Message).

send(Message) -> 
	gen_server:cast(?MODULE, {send, Message}).


start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).


% --------------------------------------------------------------------
% Function: init/1
% Description: Initiates the server
% Returns: {ok, State}          |
%          {ok, State, Timeout} |
%          ignore               |
%          {stop, Reason}
% --------------------------------------------------------------------
init([]) ->
	% {ok, Connection} =
	% amqp_connection:start(#amqp_params_network{
	% 	host = "localhost",
	% 	username           = <<"admin">>,
	%       	password           = <<"admin">>
	% }),
	% {ok, Channel} = amqp_connection:open_channel(Connection),

	% amqp_channel:call(Channel, #'exchange.declare'{exchange = <<"theExchange1">>,
	%                                            type = <<"fanout">>,
	%                                            durable = true}),

	{ok, Connection} = amqp_connection:start(#amqp_params_network{
		host = "localhost",
		username           = <<"admin">>,
	      	password           = <<"admin">>
	}),

	{ok, Channel} = amqp_connection:open_channel(Connection),
	% amqp_channel:call(Channel, #'queue.declare'{queue = <<"test_queue">>}),
	amqp_channel:call(Channel, #'queue.declare'{
	 	queue = <<"test_queue">>,
	 	passive= false,
	 	durable = true,
	 	exclusive = false,
	 	auto_delete = false,
	 	nowait = false
	 }),

	State = #state{channel = Channel},
	{ok,  State}.

% --------------------------------------------------------------------
% Function: handle_call/3
% Description: Handling call messages
% Returns: {reply, Reply, State}          |
%          {reply, Reply, State, Timeout} |
%          {noreply, State}               |
%          {noreply, State, Timeout}      |
%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%          {stop, Reason, State}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

% --------------------------------------------------------------------
% Function: handle_cast/2
% Description: Handling cast messages
% Returns: {noreply, State}          |
%          {noreply, State, Timeout} |
%          {stop, Reason, State}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_cast({send, Message}, State=#state{channel=Channel}) ->
	case erlang:is_pid(Channel) andalso glib:is_pid_alive(Channel) of 
		true -> 
			?LOG({"send", Message}),
			% amqp_channel:cast(Channel,
		 %                      #'basic.publish'{exchange = <<"theExchange1">>},
		 %                      #amqp_msg{payload = Message}),

			amqp_channel:cast(Channel,
		                      #'basic.publish'{
		                        exchange = <<"">>,
		                        routing_key = <<"test_queue">>},
		                      #amqp_msg{payload = <<"Hello World!">>}),
			ok;
		_ ->
			?LOG({"channel died !"}),
			ok
	end,
    	{noreply, State};
handle_cast(_Msg, State) ->
    {noreply, State}.

% --------------------------------------------------------------------
% Function: handle_info/2
% Description: Handling all non call/cast messages
% Returns: {noreply, State}           %          {noreply, State, Timeout} |
%          {stop, Reason, State}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_info(_Info, State) ->
    {noreply, State}.

% handle_info(Info, State) ->
%     % 接收来自go 发过来的异步消息
%     io:format("~nhandle info BBB!!============== ~n~p~n", [Info]),
%     {noreply, State}.

% --------------------------------------------------------------------
% Function: terminate/2
% Description: Shutdown the server
% Returns: any (ignored by gen_server)
% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

% --------------------------------------------------------------------
% Func: code_change/3
% Purpose: Convert process state when code is changed
% Returns: {ok, NewState}
% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

