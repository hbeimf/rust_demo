% rpc_client.erl

-module(rpc_client).

%% need this to get access to the records representing Thrift message
%% defined in thrift/example.thrift:
-include("msg_constants.hrl").

-include("msg_service_thrift.hrl").
-include_lib("glib/include/log.hrl").

-export([request/4, test/0]).

test() -> 
	request("localhost", 9090, 123, "str msg!!"),
	% request("127.0.0.1", 9999, 456, "str msg!!"),
	ok.

request(Host, Port, Id, Msg) ->
    Req = #'Message'{id = Id, text = Msg},
    {ok, Client} = thrift_client_util:new(Host, Port, msg_service_thrift, []),

    %% "hello" function per our service definition in thrift/example.thrift:
    {ClientAgain, Response} = thrift_client:call(Client, hello, [Req]),
    thrift_client:close(ClientAgain),

    % io:format("reply: ~p ~n", [Response]),
    ?LOG({reply, Response}),
    Response.
    % ok.