namespace * msg

struct Message {
  1:  i64 id,
  2:  string text
}

// query start ==============================
struct QueryReq {
  1:  i64 pool_id,
  2:  string sql
}

struct QueryReply {
  1:  i64 code,
  2:  string msg
  3:  string result
}

// query end ================================


// select  start ================================
struct SelectReq {
  1:  i64 pool_id, // 连接编号
  2:  string sql
}

// select 响应
struct SelectReply {
  1:  i64 code,  // 返回码， 1：成功， 其它失败
  2:  string msg,  // 返回描述
  3:  string result,  // 查询结果， json
}
// select end =================================

// config start =================================
struct DatabaseConfigReq {
  1:  i64 pool_id // 连接编号
}

struct DatabaseConfigReply {
  1:  i64 code,  // 返回码， 1：成功， 其它失败
  2:  string host,  // 所在主机
  3:  i64 port,  // 端口
  4:  string user,  // 连接账号
  5:  string password,  // 连接口令
  6:  string database  // 数据库
}

// config end =================================


service MsgService {
  // 获取 database config
  DatabaseConfigReply CetDatabaseConfig(1:DatabaseConfigReq q)

  // select
  SelectReply Select(1: SelectReq q)

 // api
  QueryReply QuerySql(1: QueryReq q)

}