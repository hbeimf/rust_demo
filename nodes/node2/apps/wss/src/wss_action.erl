-module(wss_action).
-compile(export_all).

-define(TIMEOUT, 5000).

-include_lib("glib/include/log.hrl").
-include_lib("sys_log/include/write_log.hrl").
-include("rr.hrl").


action(Package) -> 
    #request{from = From, req_cmd = Cmd, req_data = ReqPackage} = binary_to_term(Package),
    action(Cmd, ReqPackage, From),
    ok.


% -record(reply, {
% 	from, 
%     reply_code,
%     reply_data
% }).
action(1000, _, From) ->
    Reply = term_to_binary(#reply{from = From, reply_code = 1001, reply_data = pong}),
    self() ! {send, Reply},
    ok;
action(Cmd, ReqPackage, From) ->
    ?LOG({Cmd, ReqPackage, From}),
    ok.



