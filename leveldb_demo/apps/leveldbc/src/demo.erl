-module(demo).
-compile(export_all).

-include("log.hrl").

test() ->
	Ref = open(),
	Key = <<"test_key">>,
	eleveldb:put(Ref, Key, <<"test_val">>, []),
	R = eleveldb:get(Ref, Key, []),
	?LOG({r, R}),
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


