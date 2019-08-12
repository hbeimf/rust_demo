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
  3:  list<map<string, string>> rows
}



service MsgService {
 // api
  QueryReply querySql(1: QueryReq q)

// 分页查询表 ci_sessions  
  SelectCiSessionsReply SelectCiSessions(1: SelectCiSessionsReq q)

// test ==============
  Message hello(1: Message m)
  ServerReply AddUser(1: UserInfo info)
  ServerReply UpdateUser(1: UserInfo info)

}