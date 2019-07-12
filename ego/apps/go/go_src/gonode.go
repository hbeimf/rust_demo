package main

import (
    "bufio"
    "flag"
    "fmt"
    "log"
    "os"

    _ "./mysqlc"
    _ "./redisc"
    "./tcp_server"
    "./ws_server"
    // "./rpc"
)

var LogFile string

var err error
var PidFile string

// 根据命令行解析参数
func init() {
    flag.StringVar(&LogFile, "log", "", "log file. if not setted then output on console")
    flag.StringVar(&PidFile, "pid_file", "", "pid file path")

}

// 运行入口
// 我想把 这个集群改造成全双工的集群，所以我开始写详细的注释
// 方便自己分析
func main() {
    // // 解析命令行参数
    flag.Parse()

    setup_logging()
    write_pid()

    go tcp_server.Start()

    // go rpc.Start()

    ws_server.Start()

    return
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
