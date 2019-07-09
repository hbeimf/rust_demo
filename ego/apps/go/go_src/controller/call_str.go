package controller

import (
    "github.com/goerlang/etf"
    // "github.com/tidwall/gjson"
    "log"
    // "github.com/tidwall/gjson"
    "regexp"
    "strings"
)

// ================================================================
type StrController struct  {
    // Controller
}


// http://www.cnblogs.com/golove/p/3236300.html
// http://www.cnblogs.com/golove/p/3270918.html
// 正则表达式使用doc
// 正则表达式demo
// http://www.cnblogs.com/golove/p/3269099.html
// http://xiaorui.cc/2016/03/16/%E5%85%B3%E4%BA%8Egolang-regexp%E6%AD%A3%E5%88%99%E7%9A%84%E4%BD%BF%E7%94%A8%E6%96%B9%E6%B3%95/
// http://money.finance.sina.com.cn/corp/go.php/vMS_MarketHistory/stockid/600031.phtml?year=2017&jidu=2


//erlang 调用demo:
//gen_server:call(GoMBox, {str, str_replace, StrRes, FindStr, ReplaceTo}).
func (this *StrController) Excute(message etf.Tuple) (*etf.Term) {
    // log.Printf("message str: %#v", message)
    // log.Printf("str =========================: %#v", message[1].(string))

    switch act := message[1].(type) {
    case etf.Atom:
        if string(act) == "str_replace" {
            str := message[2].(string)
            from := message[3].(string)
            to := message[4].(string)

            replyString := str_replace(str, from, to)
            replyTerm := etf.Term(etf.Tuple{etf.Atom("ok"), replyString})
            return &replyTerm
        } else if string(act) == "trimspace" {
            str := message[2].(string)

            replyString := strings.TrimSpace(str)
            replyTerm := etf.Term(etf.Tuple{etf.Atom("ok"), replyString})
            return &replyTerm

        } else if string(act) == "contains" {
            str := message[2].(string)
            from := message[3].(string)

            Bool := strings.Contains(str, from)
            replyTerm := etf.Term(etf.Tuple{etf.Atom("ok"), Bool})
            return &replyTerm

        } else if string(act) == "has_prefix" {
            str := message[2].(string)
            from := message[3].(string)

            Bool := strings.HasPrefix(str, from)
            replyTerm := etf.Term(etf.Tuple{etf.Atom("ok"), Bool})
            return &replyTerm

        } else if string(act) == "trim" {
            str := message[2].(string)
            from := message[3].(string)

            replyString := strings.Trim(str, from)
            replyTerm := etf.Term(etf.Tuple{etf.Atom("ok"), replyString})
            return &replyTerm

        } else if string(act) == "trimleft" {
            str := message[2].(string)
            from := message[3].(string)

            replyString := strings.TrimLeft(str, from)
            replyTerm := etf.Term(etf.Tuple{etf.Atom("ok"), replyString})
            return &replyTerm

        } else if string(act) == "trimright" {
            str := message[2].(string)
            from := message[3].(string)

            replyString := strings.TrimRight(str, from)
            replyTerm := etf.Term(etf.Tuple{etf.Atom("ok"), replyString})
            return &replyTerm

        } else if string(act) == "parse_html" {

            html := byteString(message[2].([]byte))
            // log.Printf("show =========================: %#v", html)
            reg := regexp.MustCompile("\\<table id=\"FundHoldSharesTable\"[\\S\\s]+?\\</table\\>")
            matchTable := reg.FindAllString(html, -1)

            var replyTerm etf.Term
            if len(matchTable) > 0 {
                // log.Printf("matchTable =========================: %#v", matchTable)
                // log.Printf("XXmatchTable =========================: %#v", matchTable[0])
                var list etf.List
                trs := find_tr(matchTable[0])

                if len(trs) > 0 {
                    for i:=0; i<len(trs); i++ {
                        // lis = append(lis, m[i])
                        // log.Printf("tr =========================: %#v", trs[i])
                        t := find_td(trs[i])
                        if len(t) > 0 {
                            list = append(list, t)
                        }

                        log.Printf("td =========================: %#v", t)
                    }
                }
                // 返回列表　Tuple

                replyTerm = etf.Term(etf.Tuple{etf.Atom("ok"), list})
            } else {
                // log.Printf("match =========================: %#v", matchTable)
                replyTerm = etf.Term(etf.Tuple{etf.Atom("no")})
            }

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



// func (this *StrController) Excute(message etf.Tuple) (*etf.Term) {
//     // log.Printf("message str: %#v", message)

//     // log.Printf("str =========================: %#v", message[1].(string))

//     str := message[1].(string)

//     reg := regexp.MustCompile(`<li>(.*)</li>`)
//     m := reg.FindAllString(str, -1)
//     log.Printf("match =========================: %#v", m)

//     var lis etf.List
//     for i:=0; i<len(m); i++ {
//         lis = append(lis, m[i])
//     }

//     replyTerm := etf.Term(etf.Tuple{etf.Atom("ok"), lis})
//     return &replyTerm
// }



func find_tr(table string) []string {
    var trs []string
    reg := regexp.MustCompile("\\<tr[\\S\\s]+?\\</tr\\>")
    trs = reg.FindAllString(table, -1)
    return trs
}


// 返回一个Tuple
func find_td(tr string) etf.Tuple {
    reg := regexp.MustCompile("\\<td[\\S\\s]+?\\</td\\>")
    tds := reg.FindAllString(tr, -1)

    // if len(tds) > 0 {
    //     for i:=0; i<len(tds); i++ {
    //         log.Printf("td =========================: %#v", tds[i])
    //         strip_tags(tds[i])
    //     }
    // }

    var r etf.Tuple
    if len(tds) == 7 {
        r = etf.Tuple{strings.TrimSpace(strip_tags(tds[0])), strip_tags(tds[1]), strip_tags(tds[2]), strip_tags(tds[3]), strip_tags(tds[4]), strip_tags(tds[5]), strip_tags(tds[6])}
    }
    return r
}

// http://outofmemory.cn/code-snippet/2092/usage-golang-regular-expression-regexp-quchu-HTML-CSS-SCRIPT-code-jin-maintain-page-wenzi
func strip_tags(html string) string {
    // re, _ = regexp.Compile("\\<[\\S\\s]+?\\>")
    reg := regexp.MustCompile("\\<[\\S\\s]+?\\>")
    html = reg.ReplaceAllString(html, "")
    // log.Printf("con =========================: %#v", html)
    return html
}

