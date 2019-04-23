-module(code_lock).  
-behaviour(gen_fsm).  
  
% https://cryolite.iteye.com/blog/1451070
% https://blog.csdn.net/zhangzhizhen1988/article/details/7932523
% https://blog.csdn.net/yangzm/article/details/72599602
% https://www.cnblogs.com/liuweiccy/p/4679825.html

-export([start_link/1, start_link/0]).  
-export([button/1]).  
  
-export([init/1, locked/2, open/2]).  
-export([code_change/4, handle_event/3, handle_info/3, handle_sync_event/4, terminate/3]).  

-include_lib("glib/include/log.hrl").  

start_link() -> 
    start_link("abc123").

-spec(start_link(Code::string()) -> {ok,pid()} | ignore | {error,term()}).  
start_link(Code) ->  
    gen_fsm:start_link({local, ?MODULE}, ?MODULE, Code, []).  
  

% code_lock:button("123"). 
%% 发消息给状态机
-spec(button(Digit::string()) -> ok).  
button(Digit) ->  
    gen_fsm:send_event(?MODULE, {button, Digit}).  
  
init(LockCode) ->  
    % io:format("init: ~p~n", [LockCode]),  
    ?LOG([LockCode]),
    {ok, locked, {[], LockCode}}.  
  
locked({button, Digit}, {SoFar, Code}) ->  
    % io:format("buttion: ~p, So far: ~p, Code: ~p~n", [Digit, SoFar, Code]),  
    ?LOG([Digit, SoFar, Code]),
    InputDigits = lists:append(SoFar, Digit),  
    case InputDigits of  
        Code ->  
            do_unlock(),  
            {next_state, open, {[], Code}, 10000};  
        Incomplete when length(Incomplete)<length(Code) ->  
            {next_state, locked, {Incomplete, Code}, 5000};  
        Wrong ->  
            io:format("wrong passwd: ~p~n", [Wrong]),  
            {next_state, locked, {[], Code}}  
    end;  
locked(timeout, {_SoFar, Code}) ->  
    % io:format("timout when waiting button inputting, clean the input, button again plz~n"),  
    ?LOG("timout when waiting button inputting, clean the input, button again plz~n"),
    {next_state, locked, {[], Code}}.  
  
open(timeout, State) ->  
    do_lock(),  
    {next_state, locked, State};
open(Msg, State) ->
    ?LOG({"unrecgnized msg", Msg}),
    {next_state, locked, State}.
  
code_change(_OldVsn, StateName, Data, _Extra) ->  
    {ok, StateName, Data}.  
  
terminate(normal, _StateName, _Data) ->  
    ok.  
  
handle_event(Event, StateName, Data) ->  
    ?LOG("handle_event... ~n"),  
    unexpected(Event, StateName),  
    {next_state, StateName, Data}.  
  
handle_sync_event(Event, From, StateName, Data) ->  
    ?LOG({"handle_sync_event, for process: ", [From]}),  
    unexpected(Event, StateName),  
    {next_state, StateName, Data}.  
  
handle_info(Info, StateName, Data) ->  
    ?LOG("handle_info...~n"),  
    unexpected(Info, StateName),  
    {next_state, StateName, Data}.  
  
  
%% Unexpected allows to log unexpected messages  
unexpected(Msg, State) ->  
    % io:format("~p RECEIVED UNKNOWN EVENT: ~p, while FSM process in state: ~p~n",  
    %           [self(), Msg, State]).  
    ?LOG({" RECEIVED UNKNOWN EVENT: , while FSM process in state: ", self(), Msg, State}),
    ok.
%%  
%% actions  
do_unlock() ->  
    % io:format("passwd is right, open the DOOR.~n").  
    ?LOG("passwd is right, open the DOOR.~n"),
    ok.
  
do_lock() ->  
    % io:format("over, close the DOOR.~n").  
    ?LOG("over, close the DOOR.~n"),
    ok.