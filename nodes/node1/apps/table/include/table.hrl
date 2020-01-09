-record(key_pid, {
	key, 
	pid
}).


-record(cluster, {
  cluster_id,
  node_id,
  size,
  work_id,
  work_pid
}).


-record(pools, {
  pool_id,
  pool_size,
  pid,
  pool_group
}).