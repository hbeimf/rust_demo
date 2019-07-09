// tcp_echo.go

package tcp_server

import (
	"net"
	"os"
	"os/signal"
	"runtime"
	"syscall"

	"github.com/leesper/holmes"
	"github.com/leesper/tao"
	// "github.com/leesper/tao/examples/echo"

	"log"
)

// EchoServer represents the echo server.
type EchoServer struct {
	*tao.Server
}

// NewEchoServer returns an EchoServer.
func NewEchoServer() *EchoServer {
	onConnect := tao.OnConnectOption(func(conn tao.WriteCloser) bool {
		// holmes.Infoln("on connect")
		log.Println("on connect")
		return true
	})

	onClose := tao.OnCloseOption(func(conn tao.WriteCloser) {
		// holmes.Infoln("closing client")
		log.Println("closing client")
	})

	onError := tao.OnErrorOption(func(conn tao.WriteCloser) {
		// holmes.Infoln("on error")

		log.Println("on error")
	})

	onMessage := tao.OnMessageOption(func(msg tao.Message, conn tao.WriteCloser) {
		// holmes.Infoln("receving message")
		log.Println("receving message")
	})

	// 自定义编解码
	Codec := tao.CustomCodecOption(LengthValueCodec{})

	return &EchoServer{
		tao.NewServer(Codec, onConnect, onClose, onError, onMessage),
	}
}

func Start() {
	defer holmes.Start().Stop()

	runtime.GOMAXPROCS(runtime.NumCPU())

	tao.Register(Message{}.MessageNumber(), DeserializeMessage, ProcessMessage)

	l, err := net.Listen("tcp", ":12345")
	if err != nil {
		// holmes.Fatalf("listen error %v", err)
		log.Printf("Hello claims: %#v\n", err)
	}
	echoServer := NewEchoServer()

	go func() {
		c := make(chan os.Signal, 1)
		signal.Notify(c, syscall.SIGINT, syscall.SIGTERM)
		<-c
		echoServer.Stop()
	}()

	echoServer.Start(l)
}
