node/gen_server.go
进程不结束问题修复 ==================================================================================

package node

import (
    "github.com/goerlang/etf"
    "log"
    "runtime"
)

// GenServer interface
type GenServer interface {
    Init(args ...interface{})
    HandleCast(message *etf.Term)
    HandleCall(message *etf.Term, from *etf.Tuple) (reply *etf.Term)
    HandleInfo(message *etf.Term)
    Terminate(reason interface{})
}

// GenServerImpl is implementation of GenServer interface
type GenServerImpl struct {
    Node *Node   // current node of process
    Self etf.Pid // Pid of process
}

// Options returns map of default process-related options
func (gs *GenServerImpl) Options() map[string]interface{} {
    return map[string]interface{}{
        "chan-size":     100, // size of channel for regular messages
        "ctl-chan-size": 100, // size of channel for control messages
    }
}

// ProcessLoop executes during whole time of process life.
// It receives incoming messages from channels and handle it using methods of behaviour implementation
func (gs *GenServerImpl) ProcessLoop(pcs procChannels, pd Process, args ...interface{}) {
    pd.(GenServer).Init(args...)
    pcs.init <- true
    defer func() {
        if r := recover(); r != nil {
            // TODO: send message to parent process
            log.Printf("GenServer recovered: %#v", r)
        }
    }()
    for {
        var message etf.Term
        var fromPid etf.Pid
        select {
        case msg := <-pcs.in:
            message = msg
        case msgFrom := <-pcs.inFrom:
            message = msgFrom[1]
            fromPid = msgFrom[0].(etf.Pid)
        case ctlMsg := <-pcs.ctl:
            switch m := ctlMsg.(type) {
            case etf.Tuple:
                switch mtag := m[0].(type) {
                case etf.Atom:
                    switch mtag {
                    case etf.Atom("$go_ctl"):
                        nLog("Control message: %#v", m)
                    default:
                        nLog("Unknown message: %#v", m)
                    }
                default:
                    nLog("Unknown message: %#v", m)
                }
            default:
                nLog("Unknown message: %#v", m)
            }
            continue
        }
        nLog("Message from %#v", fromPid)
        switch m := message.(type) {
        case etf.Tuple:
            switch mtag := m[0].(type) {
            case etf.Atom:
                switch mtag {
                case etf.Atom("$go_ctl"):
                    nLog("Control message: %#v", message)
                case etf.Atom("$gen_call"):
                    fromTuple := m[1].(etf.Tuple)
                    reply := pd.(GenServer).HandleCall(&m[2], &fromTuple)
                    if reply != nil {
                        gs.Reply(&fromTuple, reply)
                    }
                case etf.Atom("$gen_cast"):
                    pd.(GenServer).HandleCast(&m[1])
                    switch req := (m[1]).(type) {
                    case etf.Atom:
                        // If message is atom 'stop', we should say it to main process
                        if string(req) == "stop" {
                            pd.(GenServer).Terminate(1)
                            log.Printf("结束了xxx")
                            runtime.Goexit()
                        }
                    }
                default:
                    pd.(GenServer).HandleInfo(&message)
                }
            default:
                nLog("mtag: %#v", mtag)
                pd.(GenServer).HandleInfo(&message)
            }
        default:
            nLog("m: %#v", m)
            pd.(GenServer).HandleInfo(&message)
        }
    }

    log.Printf("结束了!!!")
}

// Reply sends delayed reply at incoming `gen_server:call/2`
func (gs *GenServerImpl) Reply(fromTuple *etf.Tuple, reply *etf.Term) {
    gs.Node.Send((*fromTuple)[0].(etf.Pid), etf.Tuple{(*fromTuple)[1], *reply})
}

func (gs *GenServerImpl) setNode(node *Node) {
    gs.Node = node
}

func (gs *GenServerImpl) setPid(pid etf.Pid) {
    gs.Self = pid
}




golang iconv ==========================================================================
#cgo LDFLAGS: -liconv
http://studygolang.com/articles/7205

package iconv

/*
#cgo darwin LDFLAGS: -liconv
#cgo freebsd LDFLAGS: -liconv
#cgo windows LDFLAGS: -liconv
#include <stdlib.h>
#include <iconv.h>

// As of GO 1.6 passing a pointer to Go pointer, will lead to panic
// Therofore we use this wrapper function, to avoid passing **char directly from go
size_t call_iconv(iconv_t ctx, char *in, size_t *size_in, char *out, size_t *size_out){
        return iconv(ctx, &in, size_in, &out, size_out);
}

*/
我了个去，darwin，freebsd，windows都有。但是我在centos下使用的。难不成是这个原因，导致iconv库没有链进去？于是尝试进行了修改。

package iconv

/*
#cgo darwin LDFLAGS: -liconv
#cgo freebsd LDFLAGS: -liconv
#cgo windows LDFLAGS: -liconv
#cgo LDFLAGS: -liconv
#include <stdlib.h>
#include <iconv.h>

// As of GO 1.6 passing a pointer to Go pointer, will lead to panic
// Therofore we use this wrapper function, to avoid passing **char directly from go
size_t call_iconv(iconv_t ctx, char *in, size_t *size_in, char *out, size_t *size_out){
        return iconv(ctx, &in, size_in, &out, size_out);
}

*/
再进行编译。奇迹般的通过了，通过了，通过了。。。

好吧，目前只是这样猥琐的解决的。这样写不知道会不会对跨平台造成影响。先这样解决吧。记录一下。

如果哪位同仁看到这篇文章，觉得不是这样解决的，请不吝赐教。
