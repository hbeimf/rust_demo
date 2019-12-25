-module(glibaes128).
-compile(export_all).
% -export([encode/1, decode/1, test/0, test/1, key/0]).
-include_lib("glib/include/log.hrl").

% application:start(crypto).

% 注意： Key, IVec, PlainText 必须都为128比特，也就是16字节
test() -> 
	% Str = <<"abcdefgasdfghjkd">>,
	%Str = <<"abcdefgasdfghjkdabcdefgasdfghjkd">>,
	Str = <<"hello">>,
	Key = <<"123456">>,
	test(Str, Key).
test(Str, Key) ->
	Bin = encode(Str, Key),
	?LOG({encode, Bin}),
	R = decode(Bin, Key),
	?LOG({decode, R}),
	ok.


encode(Str) ->
	%% 按AES规则，补位
	N = 128 - (byte_size(glib:to_binary(Str)) rem 128),
	Str2 = lists:append(glib:to_str(Str), get_padding(N)),

	CipherText = crypto:block_encrypt(type(), key(), ivec(), Str2),
	base64:encode_to_string(CipherText).

encode(Str, Key) ->
	%% 按AES规则，补位
	N = 128 - (byte_size(glib:to_binary(Str)) rem 128),
	Str2 = lists:append(glib:to_str(Str), get_padding(N)),

	CipherText = crypto:block_encrypt(type(), key(Key), ivec(), Str2),
	base64:encode_to_string(CipherText).

decode(Base64) ->
	Bin = base64:decode(Base64),
	PlainAndPadding = crypto:block_decrypt(type(), key(), ivec(), Bin),

	<<PosLen/integer>> = binary_part(PlainAndPadding,{size(PlainAndPadding),-1}),
	Len = byte_size(PlainAndPadding) - PosLen,
	<<PlainText:Len/binary, _:PosLen/binary>> = PlainAndPadding,
	PlainText.

decode(Base64, Key) ->
	Bin = base64:decode(Base64),
	PlainAndPadding = crypto:block_decrypt(type(), key(Key), ivec(), Bin),

	<<PosLen/integer>> = binary_part(PlainAndPadding,{size(PlainAndPadding),-1}),
	Len = byte_size(PlainAndPadding) - PosLen,
	<<PlainText:Len/binary, _:PosLen/binary>> = PlainAndPadding,
	PlainText.

ivec() -> 
	<<"1234567890123412">>.

type() -> 
	aes_cbc128.

% key() -> 
% 	<<"asdfghkl;'][poi?">>.

key() ->
	<<"201707eggplant99">>.
	% Str = <<"anykeyisokherethisis a test key">>,
	% <<Key:16/binary, _/binary>>= glib:to_binary(glib:md5(Str)),
	% Key.

key(Str) ->
	% <<"201707eggplant99">>.
	% Str = <<"anykeyisokherethisis a test key">>,
	<<Key:16/binary, _/binary>>= glib:to_binary(glib:md5(Str)),
	Key.


get_padding(N) ->
    case N of
        0 ->
            get_padding2(128, 128, []);
        Num ->
            get_padding2(Num,Num,[])
    end.
    
get_padding2(N, Val, PaddingList) when N > 0 ->
    get_padding2(N-1, Val, [Val] ++ PaddingList);
get_padding2(N, _Val,PaddingList) when N == 0 ->
    PaddingList.