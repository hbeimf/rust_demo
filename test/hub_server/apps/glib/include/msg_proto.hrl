%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 3.26.4

-ifndef(msg_proto).
-define(msg_proto, true).

-define(msg_proto_gpb_version, "3.26.4").

-ifndef('LOGIN_PB_H').
-define('LOGIN_PB_H', true).
-record('Login',
        {uid                    :: integer() | undefined % = 1, 32 bits
        }).
-endif.

-ifndef('TESTMSG_PB_H').
-define('TESTMSG_PB_H', true).
-record('TestMsg',
        {name                   :: binary() | iolist() | undefined, % = 1
         nick_name              :: binary() | iolist() | undefined, % = 2
         phone                  :: binary() | iolist() | undefined % = 3
        }).
-endif.

-endif.
