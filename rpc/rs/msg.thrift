namespace * msg

struct Message {
  1: required  i64 id,
  2: required  string text
}

/*struct UserInfo {
  1:  i64 uid,
  2:  string name
}

// 
struct ServerReply {
  1:  i64 code,
  2:  string text
}
*/

service MsgService {
  Message hello(1: Message m)
  //ServerReply AddUser(1: UserInfo info)
  //ServerReply UpdateUser(1: UserInfo info)

}