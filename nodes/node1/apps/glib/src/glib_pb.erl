-module(glib_pb).
-compile(export_all).

% -include_lib("glib/include/action.hrl").
-include_lib("glib/include/msg_proto.hrl").
-include_lib("glib/include/log.hrl").

% message Msg{
%     uint32 action = 1;
%     bytes  msgBody = 2;
% }
msg(Action, MsgBody) -> 
	#'Msg'{
		action = Action
		,msgBody = MsgBody
	}.

encode_Msg(Action, MsgBody)->
	Msg = #'Msg'{
		action = Action
		,msgBody = MsgBody
	},
	Pb = msg_proto:encode_msg(Msg),
	Pb.

decode_Msg(DataBin) -> 
	#'Msg'{action = Action, msgBody = MsgBody} = msg_proto:decode_msg(DataBin, 'Msg'),
	{Action, MsgBody}.
