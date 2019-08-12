%%
%% Autogenerated by Thrift Compiler (0.9.3)
%%
%% DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
%%

-module(msg_types).

-include("msg_types.hrl").

-export([struct_info/1, struct_info_ext/1]).

struct_info('Message') ->
  {struct, [{1, i64},
          {2, string}]}
;

struct_info('UserInfo') ->
  {struct, [{1, i64},
          {2, string}]}
;

struct_info('ServerReply') ->
  {struct, [{1, i64},
          {2, string}]}
;

struct_info('QueryReq') ->
  {struct, [{1, i64},
          {2, string}]}
;

struct_info('QueryReply') ->
  {struct, [{1, i64},
          {2, string},
          {3, string}]}
;

struct_info('SelectCiSessionsReq') ->
  {struct, [{1, i64},
          {2, i64},
          {3, i64}]}
;

struct_info(_) -> erlang:error(function_clause).

struct_info_ext('Message') ->
  {struct, [{1, undefined, i64, 'id', undefined},
          {2, undefined, string, 'text', undefined}]}
;

struct_info_ext('UserInfo') ->
  {struct, [{1, undefined, i64, 'uid', undefined},
          {2, undefined, string, 'name', undefined}]}
;

struct_info_ext('ServerReply') ->
  {struct, [{1, undefined, i64, 'code', undefined},
          {2, undefined, string, 'text', undefined}]}
;

struct_info_ext('QueryReq') ->
  {struct, [{1, undefined, i64, 'pool_id', undefined},
          {2, undefined, string, 'sql', undefined}]}
;

struct_info_ext('QueryReply') ->
  {struct, [{1, undefined, i64, 'code', undefined},
          {2, undefined, string, 'msg', undefined},
          {3, undefined, string, 'result', undefined}]}
;

struct_info_ext('SelectCiSessionsReq') ->
  {struct, [{1, undefined, i64, 'pool_id', undefined},
          {2, undefined, i64, 'page', undefined},
          {3, undefined, i64, 'page_size', undefined}]}
;

struct_info_ext(_) -> erlang:error(function_clause).

