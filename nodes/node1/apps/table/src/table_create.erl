-module(table_create).
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").
%% 定义记录结构

-include("table.hrl").
-include_lib("glib/include/log.hrl").

-define(WAIT_FOR_TABLES, 100000).

%% 初始化mnesia表结构
init() ->

  case is_master() of
    true ->
      ?LOG("master node"),
      init_master();
    _ ->
      ?LOG("slave node"),
      init_slave(),
      ok
  end.

is_master() ->
  case nodes() of
    [] ->
      true;
    _ ->
      false
  end.

init_slave() ->
  ?LOG({"init_slave"}),
  % MasterNode = get_master_node(),
  mnesia:start(),

  [MasterNode | _] = nodes(),

  case mnesia:change_config(extra_db_nodes, [MasterNode]) of
    {ok, [MasterNode]} ->
      ?LOG({"init_slave"}),
      _Res3 = mnesia:add_table_copy(key_pid, node(), ram_copies),
      _Res4 = mnesia:add_table_copy(cluster, node(), ram_copies),
      _Res5 = mnesia:add_table_copy(pools, node(), ram_copies),

      Tables = mnesia:system_info(tables),
      mnesia:wait_for_tables(Tables, ?WAIT_FOR_TABLES);
    Any ->
      ?LOG({"init_slave", Any}),
      ok
  end,
  ok.


init_master() ->
  mnesia:stop(),
  R  = mnesia:delete_schema([node()]),
  ?LOG({node(), R, nodes()}),
  case mnesia:create_schema([node()]) of
    ok ->
      ?LOG("create and start"),
      mnesia:start(),
      mnesia:create_table(key_pid, [{attributes, record_info(fields, key_pid)}]),
      mnesia:create_table(cluster, [{attributes, record_info(fields, cluster)}]),
      mnesia:create_table(pools, [{attributes, record_info(fields, pools)}]),

      ok;
    Any ->
      ?LOG({"start", Any}),
      mnesia:start()
  end.



