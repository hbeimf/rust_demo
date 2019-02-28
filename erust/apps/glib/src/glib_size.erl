% glib_size.erl
% glib_bit.erl
-module(glib_size).
-compile(export_all).

-define(LOG(X), io:format("~n==========log========{~p,~p}==============~n~p~n", [?MODULE,?LINE,X])).
% -define(LOG(X), true).

% glib_size:size().
size() -> 
  S = <<"[{\"account\":{\"user_id\":\"1_test002\",\"behavior\":\"bet\",\"gold\":-10000,\"valid_gold\":500,\"order_id\":\"A11111\",\"game_id\":\"10000001\",\"room_id\":\"room_1\",\"seat_id\":\"1\",\"round_id\":\"R00001\",\"comment\":\"remark\"},\"game_record\":{\"user_id\":\"1_test002\",\"game_id\":\"1001\",\"room_id\":\"100001\",\"table_id\":\"1\",\"seat_id\":\"1\",\"user_count\":\"3\",\"round_id\":\"1000101\",\"card_value\":\"A1C3....\",\"init_balance\":\"1234.5\",\"all_bet\":\"111\",\"avail_bet\":\"11\",\"profit\":\"100\",\"revenue\":\"11\",\"start_time\":\"2018-11-07 09:09:09\",\"end_time\":\"2018-11-07 09:19:09\",\"channel_id\":\"1\",\"sub_channel_id\":\"1\",\"platform_profit\":\"1\"}}]">>,
 Size = erlang:byte_size(S),
 ?LOG(Size),
 
 Size1 = Size * 1000,
 ?LOG(Size1),

 Size2 = Size1 / 1024,
 ?LOG(Size2),

  ok.

