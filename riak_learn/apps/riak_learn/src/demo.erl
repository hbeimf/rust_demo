-module(demo).
-compile(export_all).

-include_lib("glib/include/log.hrl").

ping() ->
    DocIdx = riak_core_util:chash_key({<<"ping">>, term_to_binary(os:timestamp())}),
    N = 1,
    PrefList = riak_core_apl:get_primary_apl(DocIdx, N, riak_learn),
    [{IndexNode, Type}] = PrefList,
    ?LOG({DocIdx, IndexNode, Type}),
    riak_core_vnode_master:sync_spawn_command(IndexNode, ping, riak_learn_vnode_master).
