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

% // aes 加密
% message AesEncode{   
%     string  key = 1;
%     string  from = 2;
% }
encode_AesEncode(Key, From)->
	AesEncode = #'AesEncode'{
		key = Key
        , from = From
	},
	Pb = msg_proto:encode_msg(AesEncode),
	Pb.
decode_AesEncode(DataBin) -> 
	#'AesEncode'{key = Key
            , from = From
		} = msg_proto:decode_msg(DataBin,'AesEncode'),
	{Key, From}.

% // aes 解密
% message AesDecode{   
%     string  key = 1;
%     string  from = 2;
% }
encode_AesDecode(Key, From)->
	AesDecode = #'AesDecode'{
		key = Key
        , from = From
	},
	Pb = msg_proto:encode_msg(AesDecode),
	Pb.
decode_AesDecode(DataBin) -> 
	#'AesDecode'{key = Key
            , from = From
		} = msg_proto:decode_msg(DataBin,'AesDecode'),
	{Key, From}.

% // aes 解密回复 
% message AesDecodeReply{   
%     int32  code = 1;   // 1:成功； 2:失败
%     string  reply = 2;
% }
encode_AesDecodeReply(Code, Reply)->
	AesDecodeReply = #'AesDecodeReply'{
		code = Code
        , reply = Reply
	},
	Pb = msg_proto:encode_msg(AesDecodeReply),
	Pb.
decode_AesDecodeReply(DataBin) -> 
	#'AesDecodeReply'{code = Code
            , reply = Reply
		} = msg_proto:decode_msg(DataBin,'AesDecodeReply'),
	{Code, Reply}.

% message Payload{   
%     string  key = 1;
%     bytes  pack = 2;
% }
encode_Payload(Key, Pack)->
	Payload = #'Payload'{
		key = Key
        , pack = Pack
	},
	Pb = msg_proto:encode_msg(Payload),
	Pb.
decode_Payload(DataBin) -> 
	#'Payload'{key = Key
            , pack = Pack
		} = msg_proto:decode_msg(DataBin,'Payload'),
	{Key, Pack}.

% message RpcPackage{   
%     string  key = 1;  
%     int32 cmd = 2;
%     bytes payload = 3;
% }
encode_RpcPackage(Key, Cmd, Payload)->
	RpcPackage = #'RpcPackage'{
		key = Key
        , cmd = Cmd
        , payload = Payload
	},
	Pb = msg_proto:encode_msg(RpcPackage),
	Pb.
decode_RpcPackage(DataBin) -> 
	#'RpcPackage'{key = Key
            , cmd = Cmd
            , payload = Payload} = msg_proto:decode_msg(DataBin,'RpcPackage'),
	{Key, Cmd, Payload}.