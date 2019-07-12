package msg

// doc
// https://github.com/hbeimf/ProtoBuf2Leaf/blob/master/server/msg/msg.go

import (
	"github.com/name5566/leaf/network/protobuf"
)

// 使用默认的 JSON 消息处理器（默认还提供了 protobuf 消息处理器）
var Processor = protobuf.NewProcessor()

func init() {
	Processor.Register(&RpcPackage{})
	Processor.Register(&Hello{})
}
