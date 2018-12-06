-module(glibaes256).
-compile(export_all).
% -export([encode/1, decode/1, test/0, test/1, key/0]).

-include_lib("ws_server/include/log.hrl").

% application:start(crypto).

% 注意： Key, IVec, PlainText 必须都为128比特，也就是16字节
test() -> 
	% Str = <<"abcdefgasdfghjkd">>,
	%Str = <<"abcdefgasdfghjkdabcdefgasdfghjkd">>,
	Str = <<"hello">>,

	test(Str).
test(Str) ->
	Bin = encode(Str),
	?LOG({encode, Bin}),
	R = decode(Bin),
	?LOG({decode, R}),
	ok.


encode(Str) ->
	%% 按AES规则，补位
	N = 256 - (byte_size(glib:to_binary(Str)) rem 256),
	Str2 = lists:append(glib:to_str(Str), get_padding(N)),

	CipherText = crypto:block_encrypt(type(), key(), ivec(), Str2),
	base64:encode_to_string(CipherText).

decode(Base64) ->
	Bin = base64:decode(Base64),
	PlainAndPadding = crypto:block_decrypt(type(), key(), ivec(), Bin),

	<<PosLen/integer>> = binary_part(PlainAndPadding,{size(PlainAndPadding),-1}),
	Len = byte_size(PlainAndPadding) - PosLen,
	<<PlainText:Len/binary, _:PosLen/binary>> = PlainAndPadding,
	PlainText.


ivec() -> 
	<<0:128>>.

type() -> 
	aes_cbc256.

% key() -> 
% 	<<"asdfghkl;'][poi?">>.

key() ->
	Str = <<"anykeyisokherethisis a test key">>,
	<<Key:16/binary, _/binary>>= glib:to_binary(glib:md5(Str)),
	Key.


get_padding(N) ->
    case N of
        0 ->
            get_padding2(256, 256, []);
        Num ->
            get_padding2(Num,Num,[])
    end.
    
get_padding2(N, Val, PaddingList) when N > 0 ->
    get_padding2(N-1, Val, [Val] ++ PaddingList);
get_padding2(N, _Val,PaddingList) when N == 0 ->
    PaddingList.


% glibaes256:t().
t() ->
	Encode = <<"U2FsdGVkX19H3vLvW5sOyZQ1RRUsGMTBDdcLYyX+0hs=">>,
	<<Salted:8/binary, Salt:8/binary, Encrypted/binary>> = base64:decode(Encode),
	?LOG({Salted, Salt, Encrypted}),

	{Key, Iv} = get_key_iv(<<"PASSWORD">>, Salt),
	
	PlainAndPadding = crypto:block_decrypt(type(), Key, Iv, Encrypted),
	?LOG({PlainAndPadding, byte_size(PlainAndPadding)}),
	ok.

get_key_iv(Password, Salt) -> 
	?LOG({Password, Salt}),
	<<Key:32/binary, Iv:16/binary, _/binary>> = get_key_iv(Password, Salt, <<"">>, <<"">>),
	{Key, Iv}.

get_key_iv(Password, Salt, Salted, Dx) ->
	Dx1 = glib:to_binary(glib:md5(<<Dx/binary, Password/binary, Salt/binary>>)),
	case erlang:byte_size(Salted) < 48 of 
		true ->
			get_key_iv(Password, Salt, <<Salted/binary, Dx1/binary>>, Dx1);
		_ ->
			Salted
	end.
	
	


