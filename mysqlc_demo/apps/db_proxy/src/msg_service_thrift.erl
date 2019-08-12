%%
%% Autogenerated by Thrift Compiler (0.9.3)
%%
%% DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
%%

-module(msg_service_thrift).
-behaviour(thrift_service).


-include("msg_service_thrift.hrl").

-export([struct_info/1, function_info/2]).

struct_info(_) -> erlang:error(function_clause).
%%% interface
% querySql(This, Q)
function_info('querySql', params_type) ->
  {struct, [{1, {struct, {'msg_types', 'QueryReq'}}}]}
;
function_info('querySql', reply_type) ->
  {struct, {'msg_types', 'QueryReply'}};
function_info('querySql', exceptions) ->
  {struct, []}
;
% hello(This, M)
function_info('hello', params_type) ->
  {struct, [{1, {struct, {'msg_types', 'Message'}}}]}
;
function_info('hello', reply_type) ->
  {struct, {'msg_types', 'Message'}};
function_info('hello', exceptions) ->
  {struct, []}
;
% AddUser(This, Info)
function_info('AddUser', params_type) ->
  {struct, [{1, {struct, {'msg_types', 'UserInfo'}}}]}
;
function_info('AddUser', reply_type) ->
  {struct, {'msg_types', 'ServerReply'}};
function_info('AddUser', exceptions) ->
  {struct, []}
;
% UpdateUser(This, Info)
function_info('UpdateUser', params_type) ->
  {struct, [{1, {struct, {'msg_types', 'UserInfo'}}}]}
;
function_info('UpdateUser', reply_type) ->
  {struct, {'msg_types', 'ServerReply'}};
function_info('UpdateUser', exceptions) ->
  {struct, []}
;
function_info(_Func, _Info) -> erlang:error(function_clause).

