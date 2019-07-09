package model

// redis 连接池demo
//
import (
    // "github.com/garyburd/redigo/redis"
    // "time"
    // "log"
    es "github.com/mattbaird/elastigo/lib"
)

type ElasticSearch struct {
    *es.Conn
}


func NewElasticSearch(ip, port string) *ElasticSearch {
    c := es.NewConn()
    c.Domain = ip
    c.Port = port

    return &ElasticSearch{c}
}



// 增加

func (this *ElasticSearch) Insert(index, _type, id string, ttl int, v interface{}) error {
    var args map[string]interface{} = nil
    if ttl > 0 {
        args = map[string]interface{}{"ttl": ttl}
    }

    _, err := this.Index(index, _type, id, args, v)
    if err != nil {
        return err
    }

    return nil
}



// 删除

// 修改


// 查询











