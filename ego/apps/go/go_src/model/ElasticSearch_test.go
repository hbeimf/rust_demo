package model

import (
    "testing"
    // "fmt"
)

var obj = NewElasticSearch("127.0.0.1", "9200")

func TestAll(t *testing.T) {

    index := "db_100"
    table := "table_100"
    id := "id_100"

    fields := map[string]interface{}{"name": "xiaomin", "age": "10", "email":"123456@qq.com"}

    // var r map[string]interface{}
    obj.Insert(index, table, id, 30, fields)



    // t.Log("getXXX", val, err)

}


