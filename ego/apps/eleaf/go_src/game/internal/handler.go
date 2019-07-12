package internal

import (
	"reflect"

	"../../msg"

	"github.com/name5566/leaf/gate"
	"github.com/name5566/leaf/log"

	"fmt"
	"github.com/golang/protobuf/proto"
	"time"
)

func init() {
	// 向当前模块（game 模块）注册 Hello 消息的消息处理函数 handleHello
	handler(&msg.RpcPackage{}, handleRpcPackage)
	handler(&msg.Hello{}, handleHello)
}

func handler(m interface{}, h interface{}) {
	skeleton.RegisterChanRPC(reflect.TypeOf(m), h)
}

func handleHello(args []interface{}) {
	// 收到的 Hello 消息
	m := args[0].(*msg.Hello)
	// 消息的发送者
	a := args[1].(gate.Agent)

	// 输出收到的消息的内容
	log.Debug("hello %v", m.GetName())

	// 给发送者回应一个 Hello 消息
	time_str := fmt.Sprintf("%s", time.Now().Local())
	a.WriteMsg(&msg.Hello{
		Name: proto.String("Server - " + time_str)})
}

func handleRpcPackage(args []interface{}) {
	// 收到的 Hello 消息
	m := args[0].(*msg.RpcPackage)
	// 消息的发送者
	a := args[1].(gate.Agent)

	// 输出收到的消息的内容
	log.Debug("key %v", m.GetKey())
	// 输出收到的消息的内容
	// log.Debug("from %v", m.GetFrom())

	// 给发送者回应一个 Hello 消息
	a.WriteMsg(&msg.RpcPackage{
		Key:     "client",
		Cmd:     123,
		Payload: []byte{1},
	})
}
