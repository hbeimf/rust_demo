package tcp_server

import (
	"context"

	// "github.com/leesper/holmes"
	"github.com/leesper/tao"

	"log"

	"../glib"
	"github.com/golang/protobuf/proto"
)

// Message defines the echo message.
type Message struct {
	// Content string
	proto []byte
}

// Serialize serializes Message into bytes.
func (em Message) Serialize() ([]byte, error) {
	log.Printf("Serialize: %#v\n", em)

	// return []byte(em.Content), nil
	return em.proto, nil
}

// // Serialize serializes HeartBeatMessage into bytes.
// func (pb PackageMessage) Serialize() ([]byte, error) {
// 	// buf.Reset()
// 	// err := binary.Write(buf, binary.LittleEndian, hbm.Timestamp)
// 	// if err != nil {
// 	// 	return nil, err
// 	// }
// 	// return buf.Bytes(), nil
// 	return pb.proto, nil
// }

// MessageNumber returns message type number.
func (em Message) MessageNumber() int32 {
	return 1
}

// DeserializeMessage deserializes bytes into Message.
func DeserializeMessage(data []byte) (message tao.Message, err error) {
	log.Printf("DeserializeMessage: %#v\n", data)

	if data == nil {
		return nil, tao.ErrNilData
	}
	// msg := string(data)
	msg := Message{
		proto: data,
	}
	return msg, nil
}

// ProcessMessage process the logic of echo message.
func ProcessMessage(ctx context.Context, conn tao.WriteCloser) {
	log.Printf("ProcessMessage: %#v\n", ctx)

	msg := tao.MessageFromContext(ctx).(Message)

	log.Printf("receving message 62: %#v\n", msg)
	log.Printf("receving message 62: %#v\n", msg.proto)

	// 进行解码
	newAesEncode := &glib.AesEncode{}
	err := proto.Unmarshal(msg.proto, newAesEncode)
	if err != nil {
		// log.Fatal("unmarshaling error: ", err)
		log.Printf("decode package msgBytes: %#v", msg.proto)
	}

	// log.Fatalf("data mismatch %q != %q", test.GetLabel(), newTest.GetLabel())
	log.Printf("decode package Key 73: %#v", newAesEncode.GetKey())
	log.Printf("decode package From 73: %#v", newAesEncode.GetFrom())

	//
	// 创建一个消息 Test
	test := &glib.AesEncode{
		// 使用辅助函数设置域的值
		Key:  "123456",
		From: "hello world",
		// Type:  proto.Int32(17),
	}

	// 进行编码
	data, err := proto.Marshal(test)
	if err != nil {
		// log.Fatal("marshaling error: ", err)
		log.Printf("encode 93: %#v", err)
	}
	log.Printf("encode 93: %#v", data)

	// return unmarshaler(msgBytes)
	// return nil, nil

	// holmes.Infof("receving message %s\n", msg.Content)
	// conn.Write(msg.proto)
}
