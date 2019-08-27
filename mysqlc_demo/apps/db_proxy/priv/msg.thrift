namespace * msg

struct Message {
  1:  i64 id,
  2:  string text
}

struct UserInfo {
  1:  i64 uid,
  2:  string name
}

// 
struct ServerReply {
  1:  i64 code,
  2:  string text
}

// query
struct QueryReq {
  1:  i64 pool_id,
  2:  string sql
}

struct QueryReply {
  1:  i64 code,
  2:  string msg
  3:  string result
}

// 分页查询表 ci_sessions  
struct SelectCiSessionsReq {
  1:  i64 pool_id, // 连接编号
  2:  i64 page  // 第几页
  3:  i64 page_size // 每页条数
}

struct SelectCiSessionsReply {
  1:  i64 code,
  2:  string msg
  3:  list<RowCiSessions> rows
}

struct RowCiSessions {
  1:  i64 id,
  2:  string name
}


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

// 分页查询表 ci_sessions  
  SelectCiSessionsReply SelectCiSessions(1: SelectCiSessionsReq q)

// test ==============
  Message hello(1: Message m)
  ServerReply AddUser(1: UserInfo info)
  ServerReply UpdateUser(1: UserInfo info)

}