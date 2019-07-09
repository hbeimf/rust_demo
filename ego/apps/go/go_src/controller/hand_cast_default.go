package controller

import (
    "github.com/goerlang/etf"
    "github.com/goerlang/node"
    "log"
)

// ================================================================
type defaultControllerCast struct  {
    // Controller
}

func (this *defaultControllerCast) Excute(from etf.Pid, n *node.Node, message etf.Tuple) {
    log.Printf("cast message: %#v", message)


    reply_msg := etf.Term(etf.Atom("cast_default_xxx"))
    // return &replyTerm
    n.Send(from, reply_msg)
}




