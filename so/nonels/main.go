package main
 
/*
#cgo CFLAGS: -I ./
#cgo LDFLAGS: -L/erlang/rust_demo/so/lib -lhi
#include "hi.h"
 */ 
import "C"  
import "fmt"
 
func main(){
    C.hi()
    fmt.Println("Hello c, welcome to go!")

}

// https://blog.csdn.net/weixin_38374974/article/details/99842556

// https://studygolang.com/articles/11044