package controller

import (
    "github.com/goerlang/etf"
    "github.com/goerlang/node"
)

type ControllerCast interface {
    Excute(from etf.Pid, n *node.Node, message etf.Tuple)
}

var castRouters map[string]interface{}

// 根据命令行解析参数
func init() {
    // 还是一个key/value list, 用来存放异步调用的控制器
    // 根据key 先选出控制器，再处理返回，就是这么简单
    castRouters = make(map[string]interface{})
    setCastRouter()
}

func setCastRouter() {
    var ctrl listControllerCast
    addCast("list", &ctrl)

    var ctrl_default defaultControllerCast
    addCast("default", &ctrl_default)
}

func addCast(key string, controller ControllerCast) {
    castRouters[key] = controller
}

func GetCast(key string) (ctrl ControllerCast) {
    if _, ok := castRouters[key]; ok {
        return castRouters[key].(ControllerCast)
    }
    return castRouters["default"].(ControllerCast)
}
