package router

import (
	// "log"

	"github.com/gin-gonic/gin"
	"../router/ws"
)

func Init() *gin.Engine {
	// gin.SetMode(gin.ReleaseMode)
	router := gin.New()

	router.GET("/ws", func(c *gin.Context) {
		ws.Handler(c.Writer, c.Request)
	})

	return router
}
