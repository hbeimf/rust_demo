% glib_pb.erl
-module(glib_pb).
-compile(export_all).

% -include_lib("glib/include/action.hrl").
-include_lib("glib/include/msg_proto.hrl").
-include_lib("glib/include/log.hrl").


% message TestMsg{   
%     string  name = 1;
%     string  nick_name = 2;
%     string  phone  = 3;

% }
encode_TestMsg(Name, NickName, Phone)->
	TestMsg = #'TestMsg'{
		name = Name
        , nick_name = NickName
        , phone = Phone
	},
	Pb = msg_proto:encode_msg(TestMsg),
	Pb.
decode_TestMsg(DataBin) -> 
	#'TestMsg'{name = Name
            , nick_name = NickName
            , phone = Phone} = msg_proto:decode_msg(DataBin,'TestMsg'),
	{Name, NickName, Phone}.