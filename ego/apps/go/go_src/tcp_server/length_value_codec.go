package tcp_server

// length_value_codec.go
// proto doc
// https://studygolang.com/articles/2540

import (
	"bytes"
	// "context"
	"encoding/binary"
	// "fmt"
	"io"
	"net"

	// "github.com/leesper/holmes"
	"github.com/leesper/tao"

	// "../glib"
	// "github.com/golang/protobuf/proto"
	"log"
)

// LengthValueCodec defines a special codec.
// Format: type-length-value |4 bytes|4 bytes|n bytes <= 8M|
type LengthValueCodec struct{}

// Decode decodes the bytes data into Message
func (codec LengthValueCodec) Decode(raw net.Conn) (tao.Message, error) {
	// log.Printf("decode package: %#v", raw)

	// byteChan := make(chan []byte)
	// errorChan := make(chan error)

	// go func(bc chan []byte, ec chan error) {
	// 	typeData := make([]byte, tao.MessageTypeBytes)
	// 	_, err := io.ReadFull(raw, typeData)
	// 	if err != nil {
	// 		ec <- err
	// 		close(bc)
	// 		close(ec)
	// 		holmes.Debugln("go-routine read message type exited")
	// 		return
	// 	}
	// 	bc <- typeData
	// }(byteChan, errorChan)

	// var typeBytes []byte

	// select {
	// case err := <-errorChan:
	// 	return nil, err

	// case typeBytes = <-byteChan:
	// 	if typeBytes == nil {
	// 		holmes.Warnln("read type bytes nil")
	// 		return nil, tao.ErrBadData
	// 	}
	// 	typeBuf := bytes.NewReader(typeBytes)
	// 	var msgType int32
	// 	if err := binary.Read(typeBuf, binary.LittleEndian, &msgType); err != nil {
	// 		return nil, err
	// 	}

	// ======================= 读取 length ============
	lengthBytes := make([]byte, tao.MessageLenBytes)
	// lengthBytes := make([]byte, 4)

	// log.Printf("decode package lengthBytes: %#v", lengthBytes)
	// length := BytesToInt(lengthBytes)

	// log.Printf("decode package tao.MessageLenBytes: %#v", tao.MessageLenBytes)

	_, err := io.ReadFull(raw, lengthBytes)
	if err != nil {
		// log.Printf("decode package lengthBytes xxxx: %#v", length)
		return nil, err
	}

	// length := BytesToInt(lengthBytes)
	// log.Printf("decode package lengthBytes: %#v", length)

	lengthBuf := bytes.NewReader(lengthBytes)
	var msgLen uint32
	if err = binary.Read(lengthBuf, binary.LittleEndian, &msgLen); err != nil {
		// log.Printf("decode package lengthBytes yyy: %#v", length)
		return nil, err
	}
	log.Printf("decode package msgLen 88 : %#v", msgLen)
	log.Printf("decode package msgLen 89 : %#v", msgLen-4)

	if msgLen > tao.MessageMaxBytes {
		// holmes.Errorf("message(type %d) has bytes(%d) beyond max %d\n", msgType, msgLen, tao.MessageMaxBytes)
		// log.Printf("decode package lengthBytes zzz: %#v", length)
		return nil, tao.ErrBadData
	}

	log.Printf("decode package msgLen 97 : %#v", msgLen-4)

	// log.Printf("decode package lengthBytes msgLen: %#v", msgLen)

	// read application data
	// msgBytes := make([]byte, msgLen)
	msgBytes := make([]byte, msgLen-4)
	_, err = io.ReadFull(raw, msgBytes)
	if err != nil {
		log.Printf("decode package lengthBytes 106: %#v", msgBytes)
		return nil, err
	}

	// // deserialize message from bytes
	// unmarshaler := tao.GetUnmarshalFunc(msgType)
	// if unmarshaler == nil {
	// 	return nil, tao.ErrUndefined(msgType)
	// }

	// // 进行解码
	// newAesEncode := &glib.AesEncode{}
	// err = proto.Unmarshal(msgBytes, newAesEncode)
	// if err != nil {
	// 	// log.Fatal("unmarshaling error: ", err)
	// 	log.Printf("decode package msgBytes: %#v", msgBytes)
	// }
	log.Printf("decode package msgBytes 123 : %#v", msgBytes)

	// // log.Fatalf("data mismatch %q != %q", test.GetLabel(), newTest.GetLabel())
	// log.Printf("decode package Key: %#v", newAesEncode.GetKey())
	// // return unmarshaler(msgBytes)
	// // return nil, nil
	return unmarshaler(msgBytes)
	// }
}

// import (
//     "log"
//     // 辅助库
//     "github.com/golang/protobuf/proto"
//     // test.pb.go 的路径
//     "example"
// )

// func main() {
//     // 创建一个消息 Test
//     test := &example.Test{
//         // 使用辅助函数设置域的值
//         Label: proto.String("hello"),
//         Type:  proto.Int32(17),
//         Optionalgroup: &example.Test_OptionalGroup{
//             RequiredField: proto.String("good bye"),
//         },
//     }

//     // 进行编码
//     data, err := proto.Marshal(test)
//     if err != nil {
//         log.Fatal("marshaling error: ", err)
//     }

//     // 进行解码
//     newTest := &example.Test{}
//     err = proto.Unmarshal(data, newTest)
//     if err != nil {
//         log.Fatal("unmarshaling error: ", err)
//     }

//     // 测试结果
//     if test.GetLabel() != newTest.GetLabel() {
//         log.Fatalf("data mismatch %q != %q", test.GetLabel(), newTest.GetLabel())
//     }
// }

func unmarshaler(proto []byte) (tao.Message, error) {
	return PackageMessage{
		proto,
	}, nil
}

// HeartBeatMessage for application-level keeping alive.
type PackageMessage struct {
	// Timestamp int64
	proto []byte
}

// Serialize serializes HeartBeatMessage into bytes.
func (pb PackageMessage) Serialize() ([]byte, error) {
	// buf.Reset()
	// err := binary.Write(buf, binary.LittleEndian, hbm.Timestamp)
	// if err != nil {
	// 	return nil, err
	// }
	// return buf.Bytes(), nil
	return pb.proto, nil
}

// MessageNumber returns message number.
func (pb PackageMessage) MessageNumber() int32 {
	// return HeartBeat
	return 1
}

// // Decode decodes the bytes data into Message
// func (codec LengthValueCodec) Decode(raw net.Conn) (tao.Message, error) {
// 	log.Printf("decode package: %#v", raw)

// 	byteChan := make(chan []byte)
// 	errorChan := make(chan error)

// 	go func(bc chan []byte, ec chan error) {
// 		typeData := make([]byte, tao.MessageTypeBytes)
// 		_, err := io.ReadFull(raw, typeData)
// 		if err != nil {
// 			ec <- err
// 			close(bc)
// 			close(ec)
// 			holmes.Debugln("go-routine read message type exited")
// 			return
// 		}
// 		bc <- typeData
// 	}(byteChan, errorChan)

// 	var typeBytes []byte

// 	select {
// 	case err := <-errorChan:
// 		return nil, err

// 	case typeBytes = <-byteChan:
// 		if typeBytes == nil {
// 			holmes.Warnln("read type bytes nil")
// 			return nil, tao.ErrBadData
// 		}
// 		typeBuf := bytes.NewReader(typeBytes)
// 		var msgType int32
// 		if err := binary.Read(typeBuf, binary.LittleEndian, &msgType); err != nil {
// 			return nil, err
// 		}

// 		lengthBytes := make([]byte, tao.MessageLenBytes)
// 		_, err := io.ReadFull(raw, lengthBytes)
// 		if err != nil {
// 			return nil, err
// 		}
// 		lengthBuf := bytes.NewReader(lengthBytes)
// 		var msgLen uint32
// 		if err = binary.Read(lengthBuf, binary.LittleEndian, &msgLen); err != nil {
// 			return nil, err
// 		}
// 		if msgLen > tao.MessageMaxBytes {
// 			holmes.Errorf("message(type %d) has bytes(%d) beyond max %d\n", msgType, msgLen, tao.MessageMaxBytes)
// 			return nil, tao.ErrBadData
// 		}

// 		// read application data
// 		msgBytes := make([]byte, msgLen)
// 		_, err = io.ReadFull(raw, msgBytes)
// 		if err != nil {
// 			return nil, err
// 		}

// 		// deserialize message from bytes
// 		unmarshaler := tao.GetUnmarshalFunc(msgType)
// 		if unmarshaler == nil {
// 			return nil, tao.ErrUndefined(msgType)
// 		}
// 		return unmarshaler(msgBytes)
// 	}
// }

// Encode encodes the message into bytes data.
func (codec LengthValueCodec) Encode(msg tao.Message) ([]byte, error) {
	data, err := msg.Serialize()
	if err != nil {
		return nil, err
	}
	buf := new(bytes.Buffer)
	// binary.Write(buf, binary.LittleEndian, msg.MessageNumber())

	binary.Write(buf, binary.LittleEndian, int32(len(data)))
	buf.Write(data)
	packet := buf.Bytes()
	return packet, nil
}

//整形转换成字节
func IntToBytes(n int) []byte {
	x := int32(n)

	bytesBuffer := bytes.NewBuffer([]byte{})
	binary.Write(bytesBuffer, binary.BigEndian, x)
	return bytesBuffer.Bytes()
}

//字节转换成整形
func BytesToInt(b []byte) int {
	bytesBuffer := bytes.NewBuffer(b)

	var x int32
	binary.Read(bytesBuffer, binary.BigEndian, &x)

	return int(x)
}
