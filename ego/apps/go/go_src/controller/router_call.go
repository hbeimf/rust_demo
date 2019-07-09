package controller

import (
    "github.com/goerlang/etf"
)

type ControllerCall interface {
    Excute(message etf.Tuple) (*etf.Term)
}

var callRouters map[string]interface{}


func init() {
    // 定义一个key/value list , 用来存放同步调用的控制器
    callRouters = make(map[string]interface{})
    setCallRouter()
}

func setCallRouter() {
    addRouterCall("demo", &DemoController{})
    addRouterCall("list", &ListController{})
    addRouterCall("curl", &CurlController{})
    addRouterCall("iconv", &IconvController{})

    // erlang 调用示例:
    // gen_server:call(GoMBox, {str, str_replace, StrRes, FindStr, ReplaceTo}).
    addRouterCall("str", &StrController{})
    addRouterCall("time", &TimeController{})
    addRouterCall("db", &DbController{})



    addRouterCall("default", &DefaultController{})
}

// ------------------------------------------------
func addRouterCall(key string, controller ControllerCall) {
    callRouters[key] = controller
}

func GetCall(key string) (ctrl ControllerCall) {
    if _, ok := callRouters[key]; ok {
        return callRouters[key].(ControllerCall)
    }
    return callRouters["default"].(ControllerCall)
}

func HasCallController(key string) bool {
    if _, ok := callRouters[key]; ok {
        return true
    }
    return false
}


