package controller

import (
    "github.com/goerlang/etf"
    // "github.com/tidwall/gjson"
    "log"
    "io/ioutil"
    "net/http"
    // "github.com/qiniu/iconv"
    // iconv "github.com/djimenez/iconv-go"
    // iconv "github.com/djimenez/iconv-go"
)

// ================================================================
type CurlController struct  {
    // Controller
}

func (this *CurlController) Excute(message etf.Tuple) (*etf.Term) {
    log.Printf("message: %#v", message)

    url := byteString(message[1].([]byte))
    log.Printf("url: %#v", url)

    con := httpGet(url)
    // log.Printf("con: %#v", con)


    // defer resp.Body.Close()
    // input, err := ioutil.ReadAll(resp.Body)

    // out := make([]byte, len(con))
    // out = out[:]
    // iconv.Convert(con, out, "gb2312", "utf-8")
    // log.Printf("out: %#v", string(out) )

    // ioutil.WriteFile("out.html", out, 0644)


    replyTuple := etf.Tuple{etf.Atom("ok"), con}


    // replyTerm := etf.Term(etf.Atom("curl"))
    replyTerm := etf.Term(replyTuple)

    return &replyTerm
}



// http://www.01happy.com/golang-http-client-get-and-post/
func httpGet(url string) []byte {
    resp, err := http.Get(url)
    if err != nil {
        // handle error
    }

    defer resp.Body.Close()
    body, err := ioutil.ReadAll(resp.Body)
    if err != nil {
        // handle error
    }

    return body
    // return string(body)
}


// func to_utf8(str string) string {

//     // converter := iconv.NewConverter("utf-8", "windows-1252")
//     converter := iconv.NewConverter("GBK", "utf-8")


//     // output,_ := converter.ConvertString(str)
//     out:=make([]byte,len(input))

//     out=out[:]

//     iconv.Convert(input,out,"gb2312","utf-8")

//     ioutil.WriteFile("globeEarthquake_csn.html",out,0644)





//     // converter can then be closed explicitly
//     // this will also happen when garbage collected
//     converter.Close()

//     return output

// }




