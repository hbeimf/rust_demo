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
	// ======================= 读取 length ============
	lengthBytes := make([]byte, tao.MessageLenBytes)
	_, err := io.ReadFull(raw, lengthBytes)
	if err != nil {
		return nil, err
	}

	lengthBuf := bytes.NewReader(lengthBytes)
	var msgLen uint32
	if err = binary.Read(lengthBuf, binary.LittleEndian, &msgLen); err != nil {
		return nil, err
	}

	// log.Printf("decode package msgLen 88 : %#v", msgLen)
	// log.Printf("decode package msgLen 89 : %#v", msgLen-4)

	if msgLen > tao.MessageMaxBytes {
		return nil, tao.ErrBadData
	}

	// log.Printf(" =================XXXXXXXXXXXX decode package msgLen 97 : %#v", msgLen-4)

	// read application data
	// msgBytes := make([]byte, msgLen)
	msgBytes := make([]byte, msgLen-4)
	_, err = io.ReadFull(raw, msgBytes)
	if err != nil {
		log.Printf("decode package lengthBytes 106: %#v", msgBytes)
		return nil, err
	}

	// log.Printf("decode package msgBytes 123 : %#v", msgBytes)

	return unmarshaler(msgBytes)
}

func unmarshaler(proto []byte) (tao.Message, error) {
	return Message{
		proto,
	}, nil
}

// Encode encodes the message into bytes data.
func (codec LengthValueCodec) Encode(msg tao.Message) ([]byte, error) {
	log.Printf("encode =================== : %#v", msg)

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
