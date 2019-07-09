package controller

import (
    "github.com/goerlang/etf"
    // "github.com/tidwall/gjson"
    "log"
    // "github.com/tidwall/gjson"
    "regexp"
    "time"
)

// ================================================================
type TimeController struct  {
    // Controller
}

//erlang 调用demo:
//gen_server:call(GoMBox, {str, str_replace, StrRes, FindStr, ReplaceTo}).
func (this *TimeController) Excute(message etf.Tuple) (*etf.Term) {
    // log.Printf("message str: %#v", message)
    // log.Printf("str =========================: %#v", message[1].(string))

    switch act := message[1].(type) {
    case etf.Atom:
        if string(act) == "strtotime" {
            str := message[2].(string)
            //从字符串转为时间戳，第一个参数是格式，第二个是要转换的时间字符串
            tm2, _ := time.Parse("2006-01-02", str)
            replyTerm := etf.Term(tm2.Unix())
            return &replyTerm
        } else if string(act) == "time" {
            Time := time.Now().Unix()
            replyTerm := etf.Term(Time)
            return &replyTerm
        } else {
            replyTerm := etf.Term(etf.Tuple{etf.Atom("action_undefine")})
            return &replyTerm
        }
    default:
        str := message[1].(string)
        reg := regexp.MustCompile(`<li>(.*)</li>`)
        m := reg.FindAllString(str, -1)
        log.Printf("match =========================: %#v", m)

        var lis etf.List
        for i:=0; i<len(m); i++ {
            lis = append(lis, m[i])
        }

        replyTerm := etf.Term(etf.Tuple{etf.Atom("ok"), lis})
        return &replyTerm
    }

}




