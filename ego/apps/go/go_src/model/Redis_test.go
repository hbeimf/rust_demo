package model

import (
    "testing"
    // "fmt"
)

var obj = NewRedisPool("127.0.0.1:6379", 0)

func TestGet(t *testing.T) {
    val, err := obj.RedisGet("key1122")
    t.Log("getXXX", val, err)
}

func TestSetGet(t *testing.T) {
    obj.RedisSet("key100", "value_100")

    val, err := obj.RedisGet("key100")
    t.Log("设置", val, err)
}


func TestLPush(t *testing.T) {
    listName := "list100"
    obj.RedisLPush(listName, "value222")
    res, err := obj.RedisRPop(listName)
    t.Log("队列左进右出", res, err)
}



func TestSetNX(t *testing.T) {
    obj.RedisSetNX("key1000", "value_1000")

    obj.RedisEXPIRE("key1000", 30)
}



