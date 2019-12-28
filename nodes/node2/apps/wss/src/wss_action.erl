-module(wss_action).
-compile(export_all).

-define(TIMEOUT, 5000).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").

action(Package) -> 
    {From, Cmd, ReqPackage} = binary_to_term(Package),
    action(Cmd, ReqPackage, From),
    ok.

action(1000, _, From) ->
    Reply = term_to_binary({From, 1001, pong}),
    self() ! {send, Reply},
    ok;
action(Cmd, ReqPackage, From) ->
    ?LOG({Cmd, ReqPackage, From}),
    ok.



