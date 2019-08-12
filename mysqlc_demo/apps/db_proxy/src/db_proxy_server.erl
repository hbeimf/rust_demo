-module(db_proxy_server).
-include("msg_service_thrift.hrl").
-include_lib("glib/include/log.hrl").

-export([start/0, handle_function/2, say/1, stop/1, handle_error/2]).


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




% // 分页查询表 ci_sessions  
% struct SelectCiSessionsReq {
%   1:  i64 pool_id, // 连接编号
%   2:  i64 page  // 第几页
%   3:  i64 page_size // 每页条数
% }

% struct SelectCiSessionsReply {
%   1:  i64 code,
%   2:  string msg
%   3:  list<map<string, string>> rows
% }

% // 分页查询表 ci_sessions  
%   SelectCiSessionsReply SelectCiSessions(1: SelectCiSessionsReq q)

handle_function('SelectCiSessions',  {SelectCiSessionsReq}) ->

    ?LOG(SelectCiSessionsReq),
    #'SelectCiSessionsReq'{pool_id = PoolId, page = Page, page_size = PageSize} = SelectCiSessionsReq,

    Rows = [
    	dict:from_list([{<<"id">>, <<"1">>}, {<<"name">>, <<"test name">>}])
    	, dict:from_list([{<<"id">>, <<"2">>}, {<<"name">>, <<"test name 2">>}])
    ],
    {reply, #'SelectCiSessionsReply'{code = 1, msg = <<"query ok!">>, rows = Rows}};


% struct QueryReply {
%   1:  i64 code,
%   2:  string msg
%   3:  string result
% }

handle_function('querySql',  {QueryReq}) ->

    ?LOG(QueryReq),
    #'QueryReq'{pool_id = PoolId, sql = Sql} = QueryReq,
    R = mysqlc_comm:select(PoolId, Sql),
    ?LOG(R),
    {reply, #'QueryReply'{code = 1, msg = <<"query ok!">>, result = <<"res">>}};



handle_function(hello, TheMessageRecord) ->
    %% unpack these or not, whatever.  Point is it's a record:
    % _Id = TheMessageRecord#message.id,
    % _Msg = TheMessageRecord#message.text,
    % io:format("answer: ~p ~n ", [TheMessageRecord]),
    ?LOG({hello, TheMessageRecord}),
    {reply, #'Message'{id = 1, text = <<"Thanks!">>}};

handle_function('AddUser', TheMessageRecord) ->
    % io:format("answer: ~p ~n ", [TheMessageRecord]),
    ?LOG({'AddUser', TheMessageRecord}),
    {reply, #'ServerReply'{code = 200, text = <<"add user !">>}};

handle_function('UpdateUser', TheMessageRecord) ->
    ?LOG({'UpdateUser', TheMessageRecord}),
    {reply, #'ServerReply'{code = 200, text = <<"update user!">>}};

handle_function(_Function, _Args) ->
    {reply, #'Message'{id = 404, text = <<"not found!">>}}.