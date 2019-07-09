package controller

import (
    "github.com/goerlang/etf"
    "github.com/goerlang/node"
    "log"
    // "time"
    // "runtime"
)

// ================================================================
type listControllerCast struct  {
    // Controller
}

func (this *listControllerCast) Excute(from etf.Pid, n *node.Node, message etf.Tuple) {
    log.Printf("cast list: %#v", message)


    // reply_msg := etf.Term(etf.Tuple{etf.Atom("cast_list"), })
    // return &replyTerm
    // n.Send(from, reply_msg)

    var reply_msg etf.Term
    for i := 1; i <= 10; i++ {
        // time.Sleep(1*time.Second)
        reply_msg = etf.Term(etf.Tuple{etf.Atom("cast_list"), i})
        n.Send(from, reply_msg)
    }

    done := etf.Term(etf.Atom("done"))
    n.Send(from, done)

    // runtime.Goexit()
}




