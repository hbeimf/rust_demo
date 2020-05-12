% glib_fun.erl
-module(glib_fun).
-compile(export_all).
-include_lib("glib/include/log.hrl").

parse_json() ->
	Json = <<"{\"controller_name\":\"UserService\",\"method_name\":\"getByIdentity\",\"params\":[\"vY4N8JREZT+ZNgnnhAwpoKm+6ODMkZG5K9O\/hOO8Kyup1PlvvAWZh55hkm2qXPR1dyXNmsBqHZ5gdvpShhF3EOeweWK3QbIRmUNNerNdSRM=\"]}">>,
	parse_json(Json).
parse_json(Json) ->
	Data = jsx:decode(Json),
	% ?LOG(Data),
	Controller = glib_pb:get_by_key(<<"controller_name">>, Data),
	Method = glib_pb:get_by_key(<<"method_name">>, Data),
	Params = glib_pb:get_by_key(<<"params">>, Data),
	RpcToken = glib_pb:get_by_key(<<"rpc_token">>, Data),
	Rpc_request_id = glib_pb:get_by_key(<<"rpc_request_id">>, Data),

	{Controller, Method, Params, RpcToken, Rpc_request_id}.
