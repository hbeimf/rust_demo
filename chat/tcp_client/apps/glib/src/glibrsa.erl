-module(glibrsa).
% -compile(export_all).
-export([encode/1, decode/1, test/0, test/1]).
-include("log.hrl").
% ====================================
read_rsa_key(FileName) ->
    {ok, PemBin} = file:read_file(FileName),
    [Entry] = public_key:pem_decode(PemBin),
    public_key:pem_entry_decode(Entry).

rsa_public_key() ->
	PubKeyFile = glib:root_dir() ++ "config/publickey.key",
    read_rsa_key(PubKeyFile).

rsa_private_key() ->
	PriKeyFile = glib:root_dir() ++ "config/privatekey.key",
    read_rsa_key(PriKeyFile).

encode(Str) ->
 Bin =  public_key:encrypt_public(Str, rsa_public_key()),
base64:encode_to_string(Bin).


decode(Base64)->
   Bin = glib:to_binary(base64:decode_to_string(Base64)),
    public_key:decrypt_private(Bin, rsa_private_key()).

test() ->
    Msg = <<"test!">>,
    test(Msg).
test(Msg) ->
	R = encode(Msg),
	?LOG({encode, R}),
	R1 = decode(R),
	?LOG({decode, R1}),
	ok.


% private functions











