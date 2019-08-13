-module(demo).
-compile(export_all).

-include("log.hrl").

test() ->
	Ref = open(),
	Key = <<"test_key">>,
	Val = term_to_binary({test_key, <<"test_val">>}),
	eleveldb:put(Ref, Key, Val, []),
	{ok, R} = eleveldb:get(Ref, Key, []),
	?LOG({r, binary_to_term(R)}),
	eleveldb:close(Ref).
	
open() ->
	% {"../riak_learn_data/cluster_meta/trees",
             Options = [{create_if_missing,true},
              {is_internal_db,true},
              {use_bloomfilter,true},
              {write_buffer_size,7913116}],
 	DataDir = "./data",

	{ok, Ref} = eleveldb:open(DataDir, Options),
	Ref.


