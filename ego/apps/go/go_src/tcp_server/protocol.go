package tcp_server

import (
	"context"

	"github.com/leesper/holmes"
	"github.com/leesper/tao"

	"log"
)

// Message defines the echo message.
type Message struct {
	Content string
}

// Serialize serializes Message into bytes.
func (em Message) Serialize() ([]byte, error) {
	log.Printf("Serialize: %#v\n", em)

	return []byte(em.Content), nil
}

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
	msg := string(data)
	echo := Message{
		Content: msg,
	}
	return echo, nil
}

// ProcessMessage process the logic of echo message.
func ProcessMessage(ctx context.Context, conn tao.WriteCloser) {
	log.Printf("ProcessMessage: %#v\n", ctx)

	msg := tao.MessageFromContext(ctx).(Message)
	holmes.Infof("receving message %s\n", msg.Content)
	conn.Write(msg)
}
