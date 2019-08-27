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

service MsgService {
  // select
  SelectReply Select(1: SelectReq q)

 // api
  QueryReply querySql(1: QueryReq q)

}