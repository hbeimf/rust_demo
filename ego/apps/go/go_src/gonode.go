package main

import (
    "bufio"
    "flag"
    "fmt"
    "github.com/goerlang/etf"
    "github.com/goerlang/node"
    "log"
    "os"
    "strconv"
    "runtime"
    "strings"
    "./controller"
)

type srv struct {
    node.GenServerImpl
    completeChan chan bool
    serverName string
}

var SrvName string
var NodeName string
var LogFile string
var Cookie string
var err error
var EpmdPort int
var EnableRPC bool
var PidFile string

var enode *node.Node
var serverId int


// 根据命令行解析参数
func init() {
    flag.StringVar(&LogFile, "log", "", "log file. if not setted then output on console")
    flag.StringVar(&SrvName, "gen_server", "go_srv", "gonode gen_server name")
    flag.StringVar(&NodeName, "name", "gonode@localhost", "gonode node name")
    flag.StringVar(&Cookie, "cookie", "123", "cookie for gonode for interaction with erlang node")
    flag.IntVar(&EpmdPort, "epmd_port", 5588, "epmd port")
    flag.BoolVar(&EnableRPC, "rpc", false, "enable RPC")
    flag.StringVar(&PidFile, "pid_file", "", "pid file path")

    // 初始化三个变量
    // 要对新产生的协程进行命名 gs_10000, gs_10001, gs_10002 依次累加， serverId 就是个全局计数器
    flag.IntVar(&serverId, "server_id", 10000, "新进程编号")
}

// 运行入口
// 我想把 这个集群改造成全双工的集群，所以我开始写详细的注释
// 方便自己分析
func main() {
    // 解析命令行参数
    flag.Parse()

    setup_logging()
    write_pid()

    // 主要是学习大牛写的，阅读入口就是这里的两个函数
    // 启动节点
    startNode()
    // 启动第一个命名的协程
    startGenServer(SrvName)

    return
}

func startNode() {
    log.Println("node started")

    // 这里是启动node的入口 =============================
    // Initialize new node with given name and cookie
    enode = node.NewNode(NodeName, Cookie)

    // Allow node be available on EpmdPort port
    err = enode.Publish(EpmdPort)
    // end ==============================================

    if err != nil {
        log.Fatalf("Cannot publish: %s", err)
    }

    return
}


func startGenServer(serverName string) {
    // Create channel to receive message when main process should be stopped
    completeChan := make(chan bool)

    // Initialize new instance of srv structure which implements Process behaviour
    eSrv := new(srv)

    // 启动一个 process ==========================================
    // Spawn process with one arguments
    enode.Spawn(eSrv, completeChan)

    // 给进程注册一个名称
    eSrv.Node.Register(etf.Atom(serverName), eSrv.Self)
    eSrv.serverName = serverName

    // end =======================================================

    // 我主要是研究多语言集群相关的功能 ，所以这段rpc直接注释
    // RPC
    // if EnableRPC {
    //     // Create closure
    //     eClos := func(terms etf.List) (r etf.Term) {
    //         r = etf.Term(etf.Tuple{etf.Atom("gonode"), etf.Atom("reply"), len(terms)})
    //         return
    //     }

    //     // Provide it to call via RPC with `rpc:call(gonode@localhost, go_rpc, call, [as, qwe])`
    //     err = enode.RpcProvide("go_rpc", "call", eClos)
    //     if err != nil {
    //         log.Printf("Cannot provide function to RPC: %s", err)
    //     }
    // }

    // Wait to stop
    <-completeChan

    log.Println("进程结束了=========: %#v", serverName)
    return
}

// call back start ============================================================

// 协程初始化回调
// Init
func (gs *srv) Init(args ...interface{}) {
    // log.Printf("Init: %#v", args)

    // Store first argument as channel
    // gs.completeChan = args[0].(chan bool)
}

// HandleCast
// 协程接收处理异步消息回调
// Call `gen_server:cast({go_srv, gonode@localhost}, stop)` at Erlang node to stop this Go-node
func (gs *srv) HandleCast(message *etf.Term) {
    log.Printf("HandleCast: %#v", *message)

    var self_pid etf.Pid = gs.Self

    // Check type of message
    switch req := (*message).(type) {
    case etf.Tuple:
        from := req[1].(etf.Pid)

        if len(req) > 0 {
            switch act := req[0].(type) {
                case etf.Atom:
                    if string(act) == "ping" {
                        reply_msg := etf.Term(etf.Tuple{etf.Atom("pong"), etf.Pid(self_pid)})

                        // 此处由go 节点 给 erlang 节点发送消息 *****************************
                        gs.Node.Send(from, reply_msg)
                    }
                case etf.Tuple:
                    // 调用 Cast 控制器逻辑　
                    cast := controller.GetCast(string(act[0].(etf.Atom)))
                    cast.Excute(from, gs.Node, act)
            }
        }

    case etf.Atom:
        // 结束一个process
        // erlang 调用 gen_server:cast(GoMBox, stop).
        // 由我发现发送这个消息时并不会关掉process , 所以我把代码下到本地做了修改，
        // 现在是可以关掉process 的版本，
        // If message is atom 'stop', we should say it to main process
        if string(req) == "stop" {
            if gs.serverName != SrvName {
                // log.Printf("结束进程: %#v", gs.serverName)
                log.Printf("结束进程, server name: %#v", gs.serverName)
                gs.Node.Unregister(etf.Atom(gs.serverName))
                // gs.completeChan <- true
            }
        }
    }
}

// 同步消息回调
// HandleCall
// Call `gen_server:call({go_srv, gonode@localhost}, Message)` at Erlang node
func (gs *srv) HandleCall(message *etf.Term, from *etf.Tuple) (reply *etf.Term) {
    // 尝试从message 中提取信息
    switch req := (*message).(type) {
    case etf.Tuple:
        if len(req) > 0 {
            // 调用 Call 控制器逻辑
            // 根据注册的key/value控制器选出回调，调用并回复 erlang 端
            key := string(req[0].(etf.Atom))
            if controller.HasCallController(key) {
                call := controller.GetCall(key)
                reply = call.Excute(req)
            } else {
                replyTerm := etf.Term(etf.Atom("call_controller_not_define"))
                reply = &replyTerm
            }
        }
    case etf.Atom:
        if string(req) == "start_goroutine" {
            // 启动一个新process, 进程编号依次累加, 类似gs_10000, gs_为前辍
            // 给erlang 端返回  server_name:  [gs_serverId], 这样erlang 端 就可以
            // 通过 gombox给这个process发送消息了，发送方式查看erlang go:call相关代码
            serverId += 1
            serverName := "gs_" + strconv.Itoa(serverId)
            log.Printf("new goroutine 创建新协程, server name: %#v", serverName)

            eSrv := new(srv)
            gs.Node.Spawn(eSrv)
            eSrv.Node.Register(etf.Atom(serverName), eSrv.Self)
            eSrv.serverName = serverName

            replyTerm := etf.Term(etf.Tuple{etf.Atom("ok"), etf.Atom(serverName)})
            reply = &replyTerm

        } else if string(req) == "info" {
            // 查看节点上启动了的进程信息
            // erlang 通过go:info(). 查看
            // 主要查看process 总数量， 注册的process的 serverName 列表等信息，
            // 上次由于检查 stop process 是否生效调试，所以搞了个info查看功能 ，
            registered := gs.Node.Registered()

            // 协程总数量
            tupleNumGoroutine := etf.Tuple{etf.Atom("num_goroutine"), runtime.NumGoroutine()}

            // 由 erlang 注册的进程的列表, 进程数量
            var listRegisterdGoroutine etf.List
            listRegisterdGoroutineCount := 0

            // 包内部创建的协程列表，数量
            var listRegisterdGoroutineSys etf.List
            listRegisterdGoroutineSysCount := 0

            for i:=0; i<len(registered); i++{
                if strings.Contains(string(registered[i]), "gs_") {
                    listRegisterdGoroutine = append(listRegisterdGoroutine, registered[i])
                    listRegisterdGoroutineCount += 1
                } else {
                    listRegisterdGoroutineSys = append(listRegisterdGoroutineSys, registered[i])
                    listRegisterdGoroutineSysCount += 1
                }
            }
            tupleServerName := etf.Tuple{etf.Atom("registered_goroutine_name"), listRegisterdGoroutineCount, listRegisterdGoroutine}
            tupleServerNameSys := etf.Tuple{etf.Atom("registered_goroutine_name_sys"), listRegisterdGoroutineSysCount, listRegisterdGoroutineSys}

            // 返回
            replyTerm := etf.Term(etf.Tuple{etf.Atom("ok"), tupleNumGoroutine, tupleServerName, tupleServerNameSys})
            reply = &replyTerm
        }
    }

    return
}

// 按erlang 定义，这是process接收内部消息时的回调，这个节点里好像没有用到，
// HandleInfo
func (gs *srv) HandleInfo(message *etf.Term) {
    log.Printf("HandleInfo: %#v", *message)
}

// process 结束时的回调
// Terminate
func (gs *srv) Terminate(reason interface{}) {
    log.Printf("Terminate: %#v", reason.(int))
}



// call back end ============================================================================

// 其它函数暂不管
func setup_logging() {
    // Enable logging only if setted -log option
    if LogFile != "" {
        var f *os.File
        if f, err = os.Create(LogFile); err != nil {
            log.Fatal(err)
        }
        log.SetOutput(f)
    }
}

func write_pid() {
    log.Println("process pid:", os.Getpid())
    if PidFile != "" {
        file, err := os.Create(PidFile)
        if err != nil {
            log.Fatal(err)
        }
        defer file.Close()
        w := bufio.NewWriter(file)
        fmt.Fprintf(w, "%v", os.Getpid())
        w.Flush()
        log.Println("write pid in", PidFile)
    }
}

