package handler

import (
	"fmt"
	"github.com/appleboy/gin-jwt"
	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
	"log"
	"net/http"

	"../aes256"
	"../db"
	"../router/middleware"
)

var identityKey = "id"

// https://www.wafunny.com/blog/go/gin/gin.html
func RegisterHandler(c *gin.Context) {
	// name := c.DefaultPostForm("name")

}

func HelloHandler(c *gin.Context) {
	claims := jwt.ExtractClaims(c)
	log.Printf("Hello claims: %#v\n", claims)
	user, _ := c.Get(identityKey)

	log.Printf("Hello user: %#v\n", user)

	userDao := db.UserDao{}

	u3, err3 := userDao.GetUserRole(1)
	if err3 != nil {
		fmt.Println("err:", err3)
	} else {
		fmt.Println("the user role:", u3)

	}

	// encryption
	bin := aes256.Encrypt("TEXT", "PASSWORD")
	fmt.Println("aes256 encode:", bin)
	// decryption
	str := aes256.Decrypt(bin, "PASSWORD")
	fmt.Println("aes256 decode:", str)

	c.JSON(200, gin.H{
		"userID": claims["id"],
		// "userName": user.(*db.UserDao).UserName,
		"userName": user.(*middleware.User).UserName,
		"text":     "Hello World.",
		"uid":      claims["Uid"],
		"info":     u3,
	})
}

// websocket demo
var wsupgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

func WsHandler(w http.ResponseWriter, r *http.Request) {
	conn, err := wsupgrader.Upgrade(w, r, nil)
	fmt.Println(" websocket upgrade")
	if err != nil {
		fmt.Println("Failed to set websocket upgrade: %+v", err)
		return
	}

	for {
		t, msg, err := conn.ReadMessage()
		if err != nil {
			break
		}
		fmt.Println("receive msg: %s", byteString(msg))
		conn.WriteMessage(t, msg)
	}
}

func byteString(p []byte) string {
	for i := 0; i < len(p); i++ {
		if p[i] == 0 {
			return string(p[0:i])
		}
	}
	return string(p)
}
