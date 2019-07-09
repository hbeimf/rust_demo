package controller

import (
    "github.com/goerlang/etf"
    "github.com/tidwall/gjson"
    "log"
    // "github.com/tidwall/gjson"
)

// ================================================================
type DemoController struct  {
    // Controller
}

func (this *DemoController) Excute(message etf.Tuple) (*etf.Term) {
    log.Printf("message: %#v", message)

    json := byteString(message[1].([]byte))

    log.Printf("json: %#v", json)

    // json := message[1].(string)
    name := gjson.Get(json, "name")
    age := gjson.Get(json, "age")
    email := gjson.Get(json, "email")

    // log.Printf("name: %#v, val: %#v", name, name.Str)
    // log.Printf("age: %#v, val: %#v", age, age.Num )
    // log.Printf("email: %#v, val: %#v", email, email.Str)

    // 回复一个元组
    tupleAge := etf.Term(etf.Tuple{etf.Atom("age"), age.Num})
    tupleName := etf.Term(etf.Tuple{etf.Atom("name"), name.Str})
    tupleEmail := etf.Term(etf.Tuple{etf.Atom("email"), email.Str})


    // replyTerm := etf.Term(etf.Tuple{etf.Atom("go_reply"), tupleAge, tupleName, tupleEmail, etf.Pid(gs.Self), gs.serverName})
    replyTerm := etf.Term(etf.Tuple{etf.Atom("go_reply"), tupleAge, tupleName, tupleEmail})

    return &replyTerm


    // replyTerm := etf.Term(etf.Atom("do_nothing"))
    // return &replyTerm
}




