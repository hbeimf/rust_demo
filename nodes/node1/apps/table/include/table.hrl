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
