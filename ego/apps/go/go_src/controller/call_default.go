package controller

import (
    "github.com/goerlang/etf"
    // "github.com/tidwall/gjson"
    "log"
    // "github.com/tidwall/gjson"
)

// ================================================================
type DefaultController struct  {
    // Controller
}

func (this *DefaultController) Excute(message etf.Tuple) (*etf.Term) {
    log.Printf("message default: %#v", message)

    replyTerm := etf.Term(etf.Atom("default_do_nothing"))
    return &replyTerm
}




