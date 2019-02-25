% glib_bit.erl
-module(glib_bit).
-compile(export_all).
% http://erlang.org/pipermail/erlang-questions/2003-February/007507.html
-define(ENCODE_LEN, 10).
test() ->
  Bin = <<"hello world">>,
  Key = <<"test">>,
  test(Bin, Key). 

test(Bin, Key) -> 
  Bin1 = bin_bxor(Bin, Key),
  Bin2 = bin_bxor(Bin1, Key),
  Bin3 = encode(Bin, Key),
  Bin4 = encode(Bin3, Key),
  {Bin, Bin1, Bin2, Bin3, Bin4}.

encode(Package, Key) -> 
    encode_bin(glib:to_binary(Package), glib:to_binary(Key)).

encode_bin(Package, Key) when erlang:byte_size(Package) >= ?ENCODE_LEN ->
    <<RightPackage:?ENCODE_LEN/binary,OtherPageckage/binary>> = Package,
    EndoePackage = bin_bxor(RightPackage, Key),
    <<EndoePackage/binary, OtherPageckage/binary>>;
encode_bin(<<>>, Key) ->
    <<>>;
encode_bin(Package, Key) ->
    bin_bxor(Package, Key).

bin_bxor(Package, Key) ->
    Sz1 = size(Package)*8,
    Sz2 = size(Key)*8,
    <<Int1:Sz1>> = Package,
    <<Int2:Sz2>> = Key,
    Int3 = Int1 bxor Int2,
    Sz3 = max1(Sz1, Sz2),
    <<Int3:Sz3>>.

max1(Int1, Int2) when Int1 >= Int2 -> Int1;
max1(Int1, Int2) when Int1 < Int2 -> Int2.