-module(cc).
-compile(export_all).
-include_lib("glib/include/log.hrl").
-include_lib("glib/include/gw_proto.hrl").


test() -> 
	ok.




login() -> 
	Package = package_login(),
	gc:send(Package),
	ok.


package_login() -> 
	Identity = get_identity(),
	?LOG(Identity),
	Channel_id = <<"1">>,
	Pb = glib_pb:encode_VerifyReq(Identity, Channel_id),
	Package = glibpack:package(3, Pb),
	Package.


get_identity() -> 
	Url = "http://127.0.0.1:9991/UserService/userLoginSystem?username=test001&nickname=test001&platform=ios&channel_id=1&sub_channel_id=test&icon=1",
	R = glib:http_get(Url),
	% ?LOG(R),
	Data = jsx:decode(R),
	% ?LOG(Data),

	Code = glib:get_by_key(<<"code">>, Data, 1),
	case Code of 
		0 ->
			Result = glib:get_by_key(<<"result">>, Data, []),
			Identity = glib:get_by_key(<<"identity">>, Result, <<>>),
			% ?LOG(Identity),
			Identity;
		_ -> 
			<<>>
	end.


