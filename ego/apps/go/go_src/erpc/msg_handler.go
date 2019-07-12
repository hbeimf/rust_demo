package erpc

// not enough arguments in call to oprot.Flush
// thrift 版 本切换问题
// https://segmentfault.com/q/1010000014393259

import (
	"./msg"
	"fmt"
	// "git.apache.org/thrift.git/lib/go/thrift"
)

type MsgHandler struct {
	// log map[int]*shared.SharedStruct
}

func NewMsgHandler() *MsgHandler {
	return &MsgHandler{}
}

// func (p *MsgHandler) HelloVoid() (err error) {
// 	fmt.Print("helloVoid()\n")
// 	return nil
// }

// func (p *HelloHandler) Add(num1 int32, num2 int32) (retval17 int32, err error) {
// 	fmt.Print("add(", num1, ",", num2, ")\n")
// 	return num1 + num2, nil
// }

// namespace * msg

// struct Message {
//   1:  i64 id,
//   2:  string text
// }

// struct UserInfo {
//   1:  i64 uid,
//   2:  string name
// }

// //
// struct ServerReply {
//   1:  i64 code,
//   2:  string text
// }

// service MsgService {
//   Message hello(1: Message m)
//   ServerReply AddUser(1: UserInfo info)
//   ServerReply UpdateUser(1: UserInfo info)

// }

func (p *MsgHandler) Hello(m *msg.Message) (r *msg.Message, err error) {
	fmt.Print("helloVoid()\n")
	return m, nil
}

func (p *MsgHandler) AddUser(info *msg.UserInfo) (r *msg.ServerReply, err error) {
	fmt.Print("helloVoid()\n")
	return msg.NewServerReply(), nil
}

func (p *MsgHandler) UpdateUser(info *msg.UserInfo) (r *msg.ServerReply, err error) {
	fmt.Print("helloVoid()\n")
	return msg.NewServerReply(), nil
}
