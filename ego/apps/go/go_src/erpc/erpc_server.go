package erpc

// not enough arguments in call to oprot.Flush
// thrift 版 本切换问题
// https://segmentfault.com/q/1010000014393259

import (
	"./msg"
	"fmt"
	"git.apache.org/thrift.git/lib/go/thrift"
)

func Start() {
	/**
	  1. 选择 thrift协议分层 中的 传输层协议（当前选用的是BufferedTransportFactory）

	  可供选择的有5种实现了TTransportFactory
	  TBufferedTransportFactory       基于io缓冲大小的传输
	  THttpClientTransportFactory     基于http协议的传输
	  TMemoryBufferTransportFactory   基于内存方式的传输
	  StreamTransportFactory          基于文件流的传输
	  TZlibTransportFactory           基于zlib解压缩方式传输

	*/
	transportFactory := thrift.NewTBufferedTransportFactory(8192)

	/**
	  2. 选择 thrift协议分层 中的 协议层（数据封装格式）  （当前选用的是 TBinaryProtocolFactory)

	  可供选择的4种数据额封装协议（thrift版本升级之后会有更多的类型） TProtocolFactory
	  TBinaryProtocolFactory      二进制格式表示
	  TJSONProtocolFactory        JSON格式
	  TSimpleJSONProtocolFactory  Simple JSON格式
	  TCompactProtocolFactory     一种高效的编码方式

	*/
	protocolFactory := thrift.NewTBinaryProtocolFactoryDefault()

	/**
	  3. 指定Thrift需要通信的地址（本例中采用 socket方式 需要 IP地址 + 端口）

	  IP地址 + 端口号
	*/
	addr := "localhost:12306"
	var err error
	transport, err := thrift.NewTServerSocket(addr)
	if err != nil {
		fmt.Println(err)
	}
	fmt.Printf("%T\n", transport)

	/**
	  4. 选择具体的业务实现 ，完成 thrift协议分层 中的 业务处理层

	  绑定实现了 service 接口的具体的服务实现（XXXHandler）
	*/
	handler := NewMsgHandler()

	/**
	  5. 选择之前生成号的中间调用层（processor）

	  将业务实现层（handler） 和 业务自动调用层（processor）绑定
	*/
	processor := msg.NewMsgServiceProcessor(handler)

	/**
	  6. 选择一个具体的thrift服务端连接管理策略（TServer），目前只有TSimpleServer一种可用

	  TSimpleServer   go中唯一的thrift 服务端连接管理策略（为每一个连接创建一个goroutine。thrift中有很多服务端类型，0.9.2中只实现了一种）
	*/
	server := thrift.NewTSimpleServer4(processor, transport, transportFactory, protocolFactory)
	fmt.Println("Starting the simple server... on ", addr)
	/**
	  7. 开始监听 socket，处理rpc到来的请求

	  每接收一个请求，创建一个携程
	*/
	server.Serve()
}
