package controller

import (
    "github.com/goerlang/etf"
    // "github.com/tidwall/gjson"
    // "log"
    "sort"
    "time"
    "strconv"
    // "fmt"
)


// ================================================================
type ListController struct  {
    // Controller
}

func (this *ListController) Excute(message etf.Tuple) (*etf.Term) {
    // log.Printf("message: %#v", message)

    listTuple := message[1].(etf.List)
    add := message[2].(float64)
    // log.Printf("add: %#v, ", add)

    keys, listMap, vals := filter_data(listTuple)

    // log.Printf("keys: %#v, vals: %#v", keys, vals)
    // log.Printf("length: %#v, listMap: %#v", len(listMap), listMap)

    //
    min := vals[0]
    max := vals[len(vals)-1]
    cutList := cal_yid(vals, min, max, add)

    //
    ck := keys[len(keys)-1]
    tupleYid := current_yid(ck, listMap[ck], min, max, add)

    //
    group := group_list(listMap)
    var replyList etf.List
    for k, v := range group {
        r := cal_yid(v, min, max, add)
        tuple := etf.Tuple{k, r}
        replyList = append(replyList, tuple)
    }

    //
    replyTuple := etf.Tuple{tupleYid, cutList, replyList}
    replyTerm := etf.Term(replyTuple)

    // replyTerm := etf.Term(etf.Atom("ok"))
    return &replyTerm
}

func current_yid(t int, c float64, min float64, max float64, add float64) (etf.Tuple) {
    var yid int
    i := 1
    tmp := min
    for{
        start := tmp
        tmp = tmp + add * tmp
        end := tmp

        if c >= start && c < end {
            yid = i
            break
        }

        if tmp > max {
            break
        }
        i++
    }

    return etf.Tuple{t, c, yid}
}

func filter_data(listTuple etf.List) ([]int, map[int]float64, []float64) {
    var keys []int
    kvMap := make(map[int]float64)
    var vals []float64

    for _, v := range listTuple {
        tuple := v.(etf.Tuple)
        key := tuple[0].(int)

        switch tuple[1].(type) {
            case float64:
                kvMap[key] = float64(tuple[1].(float64))
            case float32:
                kvMap[key] = float64(tuple[1].(float32))
            case int64:
                kvMap[key] = float64(tuple[1].(int64))
            case int32:
                kvMap[key] = float64(tuple[1].(int32))
            case int16:
                kvMap[key] = float64(tuple[1].(int16))
            case int8:
                kvMap[key] = float64(tuple[1].(int8))
            case uint64:
                kvMap[key] = float64(tuple[1].(uint64))
            case uint32:
                kvMap[key] = float64(tuple[1].(uint32))
            case uint16:
                kvMap[key] = float64(tuple[1].(uint16))
            case uint8:
                kvMap[key] = float64(tuple[1].(uint8))
            case uint:
                kvMap[key] = float64(tuple[1].(uint))
            case int:
                kvMap[key] = float64(tuple[1].(int))
        }

        keys = append(keys, key)
        vals = append(vals, kvMap[key])
    }

    sort.Sort(sort.Float64Slice(vals))
    sort.Ints(keys)

    return keys, kvMap, vals
}

func group_list(listMap map[int]float64) (map[int][]float64) {
    group := make(map[int][]float64)
    for k, v := range listMap {
        var str_time string = time.Unix(int64(k), 0).Format("2006")
        int_time, _ := strconv.Atoi(str_time)
        group[int_time] = append(group[int_time], v)
    }

    return group
}

func cal_yid(list []float64, min float64, max float64, add float64) (etf.List) {
    var replyList etf.List
    i := 1
    tmp := min
    for{
        start := tmp
        tmp = tmp + add * tmp
        end := tmp

        tuple := etf.Tuple{i, format_float(start), format_float(end), num(start, end, list)}

        replyList = append(replyList, tuple)
        if tmp > max {
            break
        }
        i++
    }
    return replyList
}

func num(start float64, end float64, list []float64) int {
    i := 0
    for _, v := range list {
        if v >= start && v < end {
            i++
        }
    }
    return i
}

// // 精确到小数点后四位
// func format_float(num float64) float64 {
//     s := fmt.Sprintf("%.4f", num)
//     ss, _ := strconv.ParseFloat(s, 64)
//     return ss
// }
