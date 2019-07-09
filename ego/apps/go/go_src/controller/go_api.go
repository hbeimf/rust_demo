package controller

import (
    iconv "github.com/djimenez/iconv-go"
    "strconv"
    "fmt"
    "strings"
)


// 字符串替换
// http://studygolang.com/articles/2881
// package main
// import s "strings" //strings取个别名
// import "fmt"
// //我们给 fmt.Println 一个短名字的别名，我们随后将会经常用到。
// var p = fmt.Println
// func main() {
// //这是一些 strings 中的函数例子。注意他们都是包中的函数，不是字符串对象自身的方法，这意味着我们需要考虑在调用时传递字符作为第一个参数进行传递。
//     p("Contains:  ", s.Contains("test", "es"))
//     p("Count:     ", s.Count("test", "t"))
//     p("HasPrefix: ", s.HasPrefix("test", "te"))
//     p("HasSuffix: ", s.HasSuffix("test", "st"))
//     p("Index:     ", s.Index("test", "e"))
//     p("Join:      ", s.Join([]string{"a", "b"}, "-"))
//     p("Repeat:    ", s.Repeat("a", 5))
//     p("Replace:   ", s.Replace("foo", "o", "0", -1))
//     p("Replace:   ", s.Replace("foo", "o", "0", 1))
//     p("Split:     ", s.Split("a-b-c-d-e", "-"))
//     p("ToLower:   ", s.ToLower("TEST"))
//     p("ToUpper:   ", s.ToUpper("test"))
//     p()
//     p("Len: ", len("hello"))
//     p("Char:", "hello"[1])
// }
// $ go run string-functions.go
// Contains:   true
// Count:      2
// HasPrefix:  true
// HasSuffix:  true
// Index:      1
// Join:       a-b
// Repeat:     aaaaa
// Replace:    f00
// Replace:    f0o
// Split:      [a b c d e]
// toLower:    test
// ToUpper:    TEST
// Len:  5
// Char: 101



// 检查一个字符串中包含另一个字符串出现的次数
func str_count(str string, find string) int {
    return strings.Count(str, find)
}

// 检查是否包含某个子字符串
func str_contains(str string, find string) bool {
    return strings.Contains(str, find)
}

// 字符串替换
func str_replace(str string, from string, to string) string {
    return strings.Replace(str, from, to, -1)
}

// 将byte[] 转成string
func byteString(p []byte) string {
    for i := 0; i < len(p); i++ {
        if p[i] == 0 {
            return string(p[0:i])
        }
    }
    return string(p)
}

// 字符串转码
// iconv.Convert(input, out, "gb2312", "utf-8")
func iconv_str(input []byte, from string, to string) string {
    res := make([]byte, len(input))
    res = res[:]
    iconv.Convert(input, res, from, to)
    return string(res)
}

// 精确到小数点后四位
func format_float(num float64) float64 {
    s := fmt.Sprintf("%.4f", num)
    ss, _ := strconv.ParseFloat(s, 64)
    return ss
}
