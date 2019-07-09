package tcp_server

// length_value_codec.go

import (
	"bytes"
	// "context"
	"encoding/binary"
	// "fmt"
	"io"
	"net"

	"github.com/leesper/holmes"
	"github.com/leesper/tao"
)

// LengthValueCodec defines a special codec.
// Format: type-length-value |4 bytes|4 bytes|n bytes <= 8M|
type LengthValueCodec struct{}

// Decode decodes the bytes data into Message
func (codec LengthValueCodec) Decode(raw net.Conn) (tao.Message, error) {
	byteChan := make(chan []byte)
	errorChan := make(chan error)

	go func(bc chan []byte, ec chan error) {
		typeData := make([]byte, tao.MessageTypeBytes)
		_, err := io.ReadFull(raw, typeData)
		if err != nil {
			ec <- err
			close(bc)
			close(ec)
			holmes.Debugln("go-routine read message type exited")
			return
		}
		bc <- typeData
	}(byteChan, errorChan)

	var typeBytes []byte

	select {
	case err := <-errorChan:
		return nil, err

	case typeBytes = <-byteChan:
		if typeBytes == nil {
			holmes.Warnln("read type bytes nil")
			return nil, tao.ErrBadData
		}
		typeBuf := bytes.NewReader(typeBytes)
		var msgType int32
		if err := binary.Read(typeBuf, binary.LittleEndian, &msgType); err != nil {
			return nil, err
		}

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
		if msgLen > tao.MessageMaxBytes {
			holmes.Errorf("message(type %d) has bytes(%d) beyond max %d\n", msgType, msgLen, tao.MessageMaxBytes)
			return nil, tao.ErrBadData
		}

		// read application data
		msgBytes := make([]byte, msgLen)
		_, err = io.ReadFull(raw, msgBytes)
		if err != nil {
			return nil, err
		}

		// deserialize message from bytes
		unmarshaler := tao.GetUnmarshalFunc(msgType)
		if unmarshaler == nil {
			return nil, tao.ErrUndefined(msgType)
		}
		return unmarshaler(msgBytes)
	}
}

// Encode encodes the message into bytes data.
func (codec LengthValueCodec) Encode(msg tao.Message) ([]byte, error) {
	data, err := msg.Serialize()
	if err != nil {
		return nil, err
	}
	buf := new(bytes.Buffer)
	binary.Write(buf, binary.LittleEndian, msg.MessageNumber())
	binary.Write(buf, binary.LittleEndian, int32(len(data)))
	buf.Write(data)
	packet := buf.Bytes()
	return packet, nil
}
