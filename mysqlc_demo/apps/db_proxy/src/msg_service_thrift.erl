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
% Select(This, Q)
function_info('Select', params_type) ->
  {struct, [{1, {struct, {'msg_types', 'SelectReq'}}}]}
;
function_info('Select', reply_type) ->
  {struct, {'msg_types', 'SelectReply'}};
function_info('Select', exceptions) ->
  {struct, []}
;
% querySql(This, Q)
function_info('querySql', params_type) ->
  {struct, [{1, {struct, {'msg_types', 'QueryReq'}}}]}
;
function_info('querySql', reply_type) ->
  {struct, {'msg_types', 'QueryReply'}};
function_info('querySql', exceptions) ->
  {struct, []}
;
function_info(_Func, _Info) -> erlang:error(function_clause).

