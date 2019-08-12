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

struct QueryReq {
  1:  i64 pool_id,
  2:  string sql
}

service MsgService {
  Message hello(1: Message m)
  Message querySql(1: QueryReq q)
  ServerReply AddUser(1: UserInfo info)
  ServerReply UpdateUser(1: UserInfo info)

}