-module(db_proxy_server).
-include("msg_service_thrift.hrl").
-include_lib("glib/include/log.hrl").

-export([start/0, handle_function/2, say/1, stop/1, handle_error/2]).

% -compile([{parse_transform, lager_transform}]).

debug(Info)->
    io:format("Debug info:~s~n",[Info]).

say(Name)->
    io:format("~n Line:~p~n", [?LINE]),
    Sentence = "Hello," ++ Name,
    debug(Sentence),
    BinSentence = list_to_binary(Sentence),
    BinSentence.

start()->
    start(9090).

start(Port)->
    Handler = ?MODULE,
    thrift_socket_server:start([{handler, Handler},
            {service, msg_service_thrift},
            {port, Port},
            {name, msg_server}]).

stop(Server)->
    thrift_socket_server:stop(Server).


handle_error(_P1, _P2) -> 
    % io:format("error : ~p ~n ", [{P1, P2}]),
    ok.


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
handle_function('Select',  {SelectReq}) ->
    lager:info("hallo world", []),
    lager:error("hallo world", []),

    
    ?LOG(SelectReq),
    #'SelectReq'{pool_id = PoolId, sql = Sql} = SelectReq,
    ?LOG({PoolId, Sql}),

    {ok, Rows} = mysqlc_comm:select(PoolId, Sql),
    ?LOG(Rows),

    % Rows = [
    %     [{<<"id">> ,1}, {<<"name">>, <<"test1">>}]
    %     , [{<<"id">> ,2}, {<<"name">>, <<"test2">>}]
    % ],

    Result = jsx:encode(Rows),
    {reply, #'SelectReply'{code = 1, msg = <<"query ok!">>, result = Result}};

% struct QueryReply {
%   1:  i64 code,
%   2:  string msg
%   3:  string result
% }

handle_function('QuerySql',  {QueryReq}) ->

    ?LOG(QueryReq),
    #'QueryReq'{pool_id = PoolId, sql = Sql} = QueryReq,
    R = mysqlc_comm:select(PoolId, Sql),
    ?LOG(R),
    {reply, #'QueryReply'{code = 1, msg = <<"query ok!">>, result = <<"res">>}};



% struct DatabaseConfigReply {
%   1:  i64 code,  // 返回码， 1：成功， 其它失败
%   2:  string host,  // 所在主机
%   3:  i64 port,  // 端口
%   4:  string user,  // 连接账号
%   5:  string password,  // 连接口令
%   6:  string database  // 数据库
% }
handle_function('CetDatabaseConfig',  {DatabaseConfigReq}) ->

    ?LOG(DatabaseConfigReq),
    #'DatabaseConfigReq'{pool_id = PoolId} = DatabaseConfigReq,
    % R = mysqlc_comm:select(PoolId, Sql),
    % ?LOG(R),
    case mysqlc_pool:pool_config(PoolId) of 
        [] -> 
            {reply, #'DatabaseConfigReply'{code = 0, host = <<"">>, port = 0, user= <<"">>, password = <<"">>, database = <<"">>}};
        [Config|_] ->
            #{
                pool_id := PoolId1,
                host := Host, 
                port := Port, 
                user := User, 
                password := Password,
                database := Database
            } = Config,
            {reply, #'DatabaseConfigReply'{code = 1, host = Host, port = Port, user= User, password = Password, database = Database}}
    end; 

handle_function(_Function, _Args) ->
    {reply, #'Message'{id = 404, text = <<"not found!">>}}.