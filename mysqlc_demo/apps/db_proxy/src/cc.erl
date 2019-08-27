% rpc_client.erl

-module(cc).

%% need this to get access to the records representing Thrift message
%% defined in thrift/example.thrift:
-include("msg_constants.hrl").

-include("msg_service_thrift.hrl").
-include_lib("glib/include/log.hrl").

% -export([request/4, test/0, go/0]).
-compile(export_all).

% test() -> 
% 	request("localhost", 9090, 123, "str msg!!"),
% 	% request("127.0.0.1", 9999, 456, "str msg!!"),
% 	ok.

% hello() -> 
%     request("localhost", 12306, 123, "str msg!!"),
%     % request("127.0.0.1", 9999, 456, "str msg!!"),
%     ok.

% service MsgService {
%   Message hello(1: Message m)
%   ServerReply AddUser(1: UserInfo info)
%   ServerReply UpdateUser(1: UserInfo info)

% }

% add_user() ->
%     Host = "localhost", 
%     Port = 12306, 
%     % 123, "str msg!!"
%     Uid = 1234567,
%     Name = <<"jim">>,

%     UserInfoReq = #'UserInfo'{uid = Uid, name = Name},
%     {ok, Client} = thrift_client_util:new(Host, Port, msg_service_thrift, []),

%     %% "hello" function per our service definition in thrift/example.thrift:
%     {ClientAgain, Response} = thrift_client:call(Client, 'AddUser', [UserInfoReq]),
%     thrift_client:close(ClientAgain),

%     % io:format("reply: ~p ~n", [Response]),
%     ?LOG({reply, Response}),
%     Response.


% request(Host, Port, Id, Msg) ->
%     Req = #'Message'{id = Id, text = Msg},
%     {ok, Client} = thrift_client_util:new(Host, Port, msg_service_thrift, []),

%     %% "hello" function per our service definition in thrift/example.thrift:
%     {ClientAgain, Response} = thrift_client:call(Client, hello, [Req]),
%     thrift_client:close(ClientAgain),

%     % io:format("reply: ~p ~n", [Response]),
%     ?LOG({reply, Response}),
%     Response.
%     % ok.



test() ->
    lists:foreach(fun(I) -> 
        query_sql()
    end, lists:seq(1,3)),

    select().

query_sql() ->
    Host = "localhost", 
    Port = 9090, 
    % 123, "str msg!!"
    PoolId = 1,
    Sql = <<"INSERT INTO `test` (`tx`) VALUES ('2')">>,

    QueryReq = #'QueryReq'{pool_id = PoolId, sql = Sql},
    {ok, Client} = thrift_client_util:new(Host, Port, msg_service_thrift, []),

    %% "hello" function per our service definition in thrift/example.thrift:
    {ClientAgain, Response} = thrift_client:call(Client, 'querySql', [QueryReq]),
    thrift_client:close(ClientAgain),

    % io:format("reply: ~p ~n", [Response]),
    ?LOG({reply, Response}),
    Response.



% ss() -> 
%     List = lists:seq(1, 1000),
%     lists:foreach(fun(_) -> 
%         selectCiSessions()
%     end, List).
%     % selectCiSessions().

% selectCiSessions() ->
%     Host = "localhost", 
%     Port = 9090, 
%     % 123, "str msg!!"
%     PoolId = 1,
%     Sql = <<"show tables">>,

%     SelectCiSessionsReq = #'SelectCiSessionsReq'{pool_id = PoolId, page = 1, page_size = 10},
%     {ok, Client} = thrift_client_util:new(Host, Port, msg_service_thrift, []),

%     % %% "hello" function per our service definition in thrift/example.thrift:
%     % {ClientAgain, Response} = thrift_client:call(Client, 'SelectCiSessions', [SelectCiSessionsReq]),
%     % % io:format("reply: ~p ~n", [Response]),
%     % ?LOG({reply, Response}),

%     List = lists:seq(1, 1000),
%     lists:foreach(fun(_) -> 
%          {ClientAgain, Response} = thrift_client:call(Client, 'SelectCiSessions', [SelectCiSessionsReq]),
%          ?LOG({reply, Response}),
%          ok
%     end, List),

%     thrift_client:close(Client),
%     ok.



% // select  start ================================
% struct SelectReq {
%   1:  i64 pool_id, // 连接编号
%   2:  string sql
% }

% // select 响应
% struct SelectReply {
%   1:  i64 code,  // 返回码， 1：成功， 其它失败
%   2:  string msg,  // 返回描述
%   3:  string result,  // 查询结果， json
% }
% // select end =================================
select() -> 
    Host = "localhost", 
    Port = 9090, 
    % 123, "str msg!!"
    PoolId = 1,
    Sql = <<"select * from test limit 3">>,

    SelectReq = #'SelectReq'{pool_id = PoolId, sql = Sql},
    {ok, Client} = thrift_client_util:new(Host, Port, msg_service_thrift, []),

    %% "hello" function per our service definition in thrift/example.thrift:
    {ClientAgain, Response} = thrift_client:call(Client, 'Select', [SelectReq]),
    ?LOG({reply, Response}),

    thrift_client:close(ClientAgain),
    ok.
