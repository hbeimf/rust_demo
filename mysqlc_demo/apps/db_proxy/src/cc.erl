% rpc_client.erl

-module(cc).

%% need this to get access to the records representing Thrift message
%% defined in thrift/example.thrift:
-include("msg_constants.hrl").

-include("msg_service_thrift.hrl").
-include_lib("glib/include/log.hrl").

% -export([request/4, test/0, go/0]).
-compile(export_all).

test() -> 
	request("localhost", 9090, 123, "str msg!!"),
	% request("127.0.0.1", 9999, 456, "str msg!!"),
	ok.

hello() -> 
    request("localhost", 12306, 123, "str msg!!"),
    % request("127.0.0.1", 9999, 456, "str msg!!"),
    ok.

% service MsgService {
%   Message hello(1: Message m)
%   ServerReply AddUser(1: UserInfo info)
%   ServerReply UpdateUser(1: UserInfo info)

% }

add_user() ->
    Host = "localhost", 
    Port = 12306, 
    % 123, "str msg!!"
    Uid = 1234567,
    Name = <<"jim">>,

    UserInfoReq = #'UserInfo'{uid = Uid, name = Name},
    {ok, Client} = thrift_client_util:new(Host, Port, msg_service_thrift, []),

    %% "hello" function per our service definition in thrift/example.thrift:
    {ClientAgain, Response} = thrift_client:call(Client, 'AddUser', [UserInfoReq]),
    thrift_client:close(ClientAgain),

    % io:format("reply: ~p ~n", [Response]),
    ?LOG({reply, Response}),
    Response.


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


query_sql() ->
    Host = "localhost", 
    Port = 9090, 
    % 123, "str msg!!"
    PoolId = 1,
    Sql = <<"show tables">>,

    QueryReq = #'QueryReq'{pool_id = PoolId, sql = Sql},
    {ok, Client} = thrift_client_util:new(Host, Port, msg_service_thrift, []),

    %% "hello" function per our service definition in thrift/example.thrift:
    {ClientAgain, Response} = thrift_client:call(Client, 'querySql', [QueryReq]),
    thrift_client:close(ClientAgain),

    % io:format("reply: ~p ~n", [Response]),
    ?LOG({reply, Response}),
    Response.


selectCiSessions() ->
    Host = "localhost", 
    Port = 9090, 
    % 123, "str msg!!"
    PoolId = 1,
    Sql = <<"show tables">>,

    SelectCiSessionsReq = #'SelectCiSessionsReq'{pool_id = PoolId, page = 1, page_size = 10},
    {ok, Client} = thrift_client_util:new(Host, Port, msg_service_thrift, []),

    %% "hello" function per our service definition in thrift/example.thrift:
    {ClientAgain, Response} = thrift_client:call(Client, 'SelectCiSessions', [SelectCiSessionsReq]),
    thrift_client:close(ClientAgain),

    % io:format("reply: ~p ~n", [Response]),
    ?LOG({reply, Response}),
    Response.