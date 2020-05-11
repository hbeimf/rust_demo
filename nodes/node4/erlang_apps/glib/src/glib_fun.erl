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


% test() ->
%   % A = [{<<"nickname">>,
%   % <<232,162,156,231,187,138,231,151,158,231,149,148,228,185,177,229,186,
%   %   147,233,170,143,232,130,140,232,146,130>>}],
%   A = [{<<"nickname">>,<<"KWBZAQ_16929">>}],
%   ?LOG(jsx:encode(A)),
%   A1 = glib:get_by_key(<<"nickname">>, A),
%   B = binary:bin_to_list(A1),
%   C = lists:reverse(B),
%   [F1|_] = C,
  
%   ?LOG(F1),
%   case F1 =< 57 andalso F1 >= 48 of
%     true -> %说明是数字
%     false -> %说明不是数字
%   ok.


% 1> Bin = <<1,2,3,4,5,6,7,8,9,10>>.
% 2> binary:part(Bin, {byte_size(Bin), -5}).
% <<6,7,8,9,10>>
tt() ->
	Bin = <<"KWBZAQ_16929">>,
	R = binary:part(Bin, {byte_size(Bin), -3}),
	try
    	R1 = binary_to_integer(R),
    	?LOG({r, R}),
    	{true, R1}
	catch
		_K:_Error_msg ->
		  false
	end.


tt(Bin) ->
	% Bin = <<"KWBZAQ_16929">>,
	R = binary:part(Bin, {byte_size(Bin), -3}),
	try
    	R1 = binary_to_integer(R),
    	?LOG({r, R}),
    	{true, R1}
	catch
		_K:_Error_msg ->
		  false
	end.