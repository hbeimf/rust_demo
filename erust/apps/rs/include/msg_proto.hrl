%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.0.2

-ifndef(msg_proto).
-define(msg_proto, true).

-define(msg_proto_gpb_version, "4.0.2").

-ifndef('RPCPACKAGE_PB_H').
-define('RPCPACKAGE_PB_H', true).
-record('RpcPackage',
        {key = <<>>             :: iodata() | undefined, % = 1
         payload = <<>>         :: binary() | undefined % = 2
        }).
-endif.

-ifndef('LOGIN_PB_H').
-define('LOGIN_PB_H', true).
-record('Login',
        {uid = 0                :: integer() | undefined % = 1, 32 bits
        }).
-endif.

-ifndef('TESTMSG_PB_H').
-define('TESTMSG_PB_H', true).
-record('TestMsg',
        {name = <<>>            :: iodata() | undefined, % = 1
         nick_name = <<>>       :: iodata() | undefined, % = 2
         phone = <<>>           :: iodata() | undefined % = 3
        }).
-endif.

-endif.
