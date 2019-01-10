% demo_receive.erl
% rabbit_sub_work.erl
% rabbit_send.erl
%% gen_server代码模板

-module(demo_receive).

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

% -export([pub/0, pub/1]).

-include_lib("amqp_client/include/amqp_client.hrl").
-include_lib("glib/include/log.hrl").


% -define(LOG(X), io:format("~n==========log========{~p,~p}==============~n~p~n", [?MODULE,?LINE,X])).
% -define(LOG(X), true).

% pub() -> 
% 	Message = <<"info: Hello World!">>,
% 	pub(Message).

% pub(Message) -> 
% 	gen_server:cast(?MODULE, {pub, Message}).


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
	 {ok, Connection} =
        	amqp_connection:start(#amqp_params_network{
        	host = "localhost",
        	username           = <<"admin">>,
              password           = <<"admin">>
             }),
	{ok, Channel} = amqp_connection:open_channel(Connection),

	% 一旦申明了一个交换机，就不能轻易改变交换机的属性重新申明，　如durable由true 改成false，　一旦改变就会报错
	%　除非先删除旧的申明　，

	% amqp_channel:call(Channel, #'exchange.declare'{exchange = <<"theExchange1">>,
	%                                                type = <<"fanout">>,
	%                                                durable = true}),

	% #'queue.declare_ok'{queue = Queue} =
	%     amqp_channel:call(Channel, #'queue.declare'{exclusive = true}),

	% amqp_channel:call(Channel, #'queue.bind'{exchange = <<"theExchange1">>,
	%                                          queue = Queue}),

	% % io:format(" [*] Waiting for logs. To exit press CTRL+C~n"),
	% ?LOG({"[*] Waiting for logs.", Channel}),

	% amqp_channel:subscribe(Channel, #'basic.consume'{queue = Queue,
	%                                                  no_ack = true}, self()),
	% receive
	%     #'basic.consume_ok'{} -> ok
	% end,

	% //queue: &str, passive: bool, durable: bool, exclusive: bool, auto_delete: bool, nowait: bool, arguments: Table
	% queue_name, false, true, false, false, false, Table::new()
	 amqp_channel:call(Channel, #'queue.declare'{
	 	queue = <<"test_queue">>,
	 	passive= false,
	 	durable = true,
	 	exclusive = false,
	 	auto_delete = false,
	 	nowait = false
	 }),
	?LOG(" [*] Waiting for messages. To exit press CTRL+C~n"),

	amqp_channel:subscribe(Channel, #'basic.consume'{queue = <<"test_queue">>,
	                                                 no_ack = true}, self()),
	% receive
	%     #'basic.consume_ok'{} -> ok
	% end,

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
handle_call(Request, _From, State) ->
	?LOG({call, Request}),
	Reply = ok,
	{reply, Reply, State}.

% --------------------------------------------------------------------
% Function: handle_cast/2
% Description: Handling cast messages
% Returns: {noreply, State}          |
%          {noreply, State, Timeout} |
%          {stop, Reason, State}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_cast(Msg, State) ->
	?LOG({cast, Msg}),
	{noreply, State}.

% --------------------------------------------------------------------
% Function: handle_info/2
% Description: Handling all non call/cast messages
% Returns: {noreply, State}           %          {noreply, State, Timeout} |
%          {stop, Reason, State}            (terminate/2 is called)
% --------------------------------------------------------------------
handle_info({#'basic.deliver'{}, #amqp_msg{payload = Body}}, State) ->
	?LOG({payload, Body}),
	{noreply, State};
handle_info(Info, State) ->
	?LOG({info, Info}),
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

