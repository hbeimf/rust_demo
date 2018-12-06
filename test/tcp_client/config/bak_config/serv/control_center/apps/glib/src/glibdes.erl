-module(glibdes).

-define(DES_KEY, des_key).
-define(CHARSET, charset).

-export([encode/1,decode/1,
         encode/3,decode/3, test/0]).

-include_lib("ws_server/include/log.hrl").

test() -> 
	Str = <<"this is a test!!!">>,
	{ok, Bin} = encode(Str),
	?LOG({encode, Bin}),
	R = decode(Bin),
	?LOG({decode, R}),
	ok.

encode(PlainText) ->
    Key = key(),
    Charset = utf8,
    encode(PlainText, Key, Charset).

decode(Ciphertext) ->
    Key = key(),
    Charset = utf8,
    decode(Ciphertext, Key, Charset).

key() -> 
	"abcdefgh". %% 8 位

%% des 加密
encode(PlainText, Key, Charset) ->
    Key2 = unicode:characters_to_list(Key, Charset),
    Ivec = <<1,2,3,4,5,6,7,8>>,

    %% 按DES规则，补位
    N = 8 - (byte_size(glib:to_binary(PlainText)) rem 8),
    PlainText2 = lists:append(glib:to_str(PlainText), get_padding(N)),
    %% 加密
    Ciphertext = crypto:block_encrypt(des_cbc, Key2, Ivec, PlainText2),
    {ok, Ciphertext}.


%% des 解密
decode(Ciphertext, Key, Charset) ->

    Key2 = unicode:characters_to_list(Key, Charset),
    Ivec = <<1,2,3,4,5,6,7,8>>,
    case is_list(Ciphertext) of
        true ->
            CipherBin = glib:to_binary(Ciphertext);
        false ->
            CipherBin = Ciphertext
    end,
    
    PlainAndPadding = crypto:block_decrypt(des_cbc,Key2,Ivec,CipherBin),
    <<PosLen/integer>> = binary_part(PlainAndPadding,{size(PlainAndPadding),-1}),
    Len = byte_size(PlainAndPadding) - PosLen,
    <<PlainText:Len/binary, _:PosLen/binary>> = PlainAndPadding,
    {ok, PlainText}.
    

get_padding(N) ->
    case N of
        0 ->
            get_padding2(8,8,[]);
        Num ->
            get_padding2(Num,Num,[])
    end.
    
get_padding2(N, Val, PaddingList) when N > 0 ->
    get_padding2(N-1, Val, [Val] ++ PaddingList);
get_padding2(N, _Val,PaddingList) when N == 0 ->
    PaddingList.