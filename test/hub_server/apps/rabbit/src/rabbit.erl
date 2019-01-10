-module(rabbit).
-compile(export_all).

-include_lib("amqp_client/include/amqp_client.hrl").
% -include_lib("amqp_client/include/amqp_client.hrl").


% 启动pub/sub 生产者
emit_log() ->
    {ok, Connection} =
        amqp_connection:start(#amqp_params_network{
        	host = "localhost",
        	username           = <<"admin">>,
              password           = <<"admin">>
        }),
    {ok, Channel} = amqp_connection:open_channel(Connection),

    amqp_channel:call(Channel, #'exchange.declare'{exchange = <<"theExchange1">>,
                                                   type = <<"fanout">>,
                                                   durable = true}),

    Message = <<"info: Hello World!">>,

    amqp_channel:cast(Channel,
                      #'basic.publish'{exchange = <<"theExchange1">>},
                      #amqp_msg{payload = Message}),
    io:format(" [x] Sent ~p~n", [Message]),
    ok = amqp_channel:close(Channel),
    ok = amqp_connection:close(Connection),
    ok.

% 启动pub/sub消费者
receive_demo() ->
    spawn(fun() ->
        receive_logs()
    end).

% 启动pub/sub消费者
receive_logs() ->
    {ok, Connection} =
        amqp_connection:start(#amqp_params_network{
        	host = "localhost",
        	username           = <<"admin">>,
              password           = <<"admin">>
             }),
    {ok, Channel} = amqp_connection:open_channel(Connection),

    % 一旦申明了一个交换机，就不能轻易改变交换机的属性重新申明，　如durable由true 改成false，　一旦改变就会报错
    %　除非先删除旧的申明　，

    amqp_channel:call(Channel, #'exchange.declare'{exchange = <<"theExchange1">>,
                                                   type = <<"fanout">>,
                                                   durable = true}),

    #'queue.declare_ok'{queue = Queue} =
        amqp_channel:call(Channel, #'queue.declare'{exclusive = true}),

    amqp_channel:call(Channel, #'queue.bind'{exchange = <<"theExchange1">>,
                                             queue = Queue}),

    io:format(" [*] Waiting for logs. To exit press CTRL+C~n"),

    amqp_channel:subscribe(Channel, #'basic.consume'{queue = Queue,
                                                     no_ack = true}, self()),
    receive
        #'basic.consume_ok'{} -> ok
    end,
    loop(Channel).

loop(Channel) ->
    receive
        {#'basic.deliver'{}, #amqp_msg{payload = Body}} ->
            io:format(" [xxx] ~p~n", [Body]),
            loop(Channel)
    end.

% 目前，这个函数是可以工作的, 对应 receive
receive_xx() ->
    {ok, Connection} =
        amqp_connection:start(#amqp_params_network{host = "localhost"}),
    {ok, Channel} = amqp_connection:open_channel(Connection),

    amqp_channel:call(Channel, #'queue.declare'{queue = <<"hello">>}),
    io:format(" [*] Waiting for messages. To exit press CTRL+C~n"),

    amqp_channel:subscribe(Channel, #'basic.consume'{queue = <<"hello">>,
                                                     no_ack = true}, self()),
    receive
        #'basic.consume_ok'{} -> ok
    end,
    loop(Channel).


% loop(Channel) ->
%     receive
%         {#'basic.deliver'{}, #amqp_msg{payload = Body}} ->
%             io:format(" [x] Received ~p~n", [Body]),
%             loop(Channel)
%     end.