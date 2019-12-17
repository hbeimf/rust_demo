% glib_pb.erl
-module(glib_pb).
-compile(export_all).




-include_lib("glib/include/msg_proto.hrl").

test() ->
	Key = <<"123">>,
	Str = <<"xx">>,
	AesEncode = #'AesEncode'{
                        key = Key,
                        from = Str
                    },
	AesEncodeBin = msg_proto:encode_msg(AesEncode),
	AesEncodeBin.




