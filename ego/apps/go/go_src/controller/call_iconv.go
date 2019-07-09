package controller

import (
    "github.com/goerlang/etf"
    "log"
)

// ================================================================
type IconvController struct  {
    // Controller
}

func (this *IconvController) Excute(message etf.Tuple) (*etf.Term) {
    log.Printf("message iconv : %#v", message)

    from := string(message[2].(etf.Atom))
    to := string(message[3].(etf.Atom))

    reply := iconv_str(message[1].([]byte), from, to)

    replyTuple := etf.Tuple{etf.Atom("ok"), reply}

    // replyTerm := etf.Term(etf.Atom("curl"))
    replyTerm := etf.Term(replyTuple)

    return &replyTerm
}


