package router

import (
	// "log"

	// "github.com/appleboy/gin-jwt"
	// "github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	// "../handler"
	// "../redisc"
	// "../router/middleware"
	"../router/ws"
)

func Init() *gin.Engine {
	// gin.SetMode(gin.ReleaseMode)
	router := gin.New()

	// websocket
	// router.LoadHTMLFiles("index.html")
	// router.GET("/", func(c *gin.Context) {
	// 	c.HTML(200, "index.html", nil)
	// })
	// router.GET("/ws", func(c *gin.Context) {
	// 	handler.WsHandler(c.Writer, c.Request)
	// })

	//websocket chat
	// redis sub

	// go redisc.RedisClient.RedisSub("kuaisan-channel")

	// router.LoadHTMLFiles("home.html")
	// router.GET("/chat", func(c *gin.Context) {
	// 	c.HTML(200, "home.html", nil)
	// })

	router.GET("/wschat", func(c *gin.Context) {
		ws.Handler(c.Writer, c.Request)
	})

	// router.Use(gin.Logger())
	// router.Use(gin.Recovery())

	// // 允许垮域访问
	// config := cors.DefaultConfig()
	// config.AllowOrigins = []string{"http://baidu.com"}
	// // config.AllowOrigins == []string{"http://baidu.com", "http://baidu1.com"}
	// router.Use(cors.New(config))

	// // the jwt middleware
	// authMiddleware, err := middleware.New()

	// if err != nil {
	// 	log.Fatal("JWT Error:" + err.Error())
	// }

	// router.POST("/login", authMiddleware.LoginHandler)
	// router.POST("/register", handler.RegisterHandler)

	// router.NoRoute(authMiddleware.MiddlewareFunc(), func(c *gin.Context) {
	// 	claims := jwt.ExtractClaims(c)
	// 	log.Printf("NoRoute claims: %#v\n", claims)
	// 	c.JSON(404, gin.H{"code": "PAGE_NOT_FOUND", "message": "Page not found"})
	// })

	// adminGroup := router.Group("/api/admin")
	// adminGroup.Use(authMiddleware.MiddlewareFunc())
	// {
	// 	adminGroup.GET("/hello", handler.HelloHandler)
	// 	adminGroup.GET("/refresh_token", authMiddleware.RefreshHandler)
	// 	// adminGroup.GET("/hello", helloHandler)
	// }

	// clientGroup := router.Group("/api/client")
	// clientGroup.Use(authMiddleware.MiddlewareFunc())
	// {
	// 	clientGroup.GET("/hello", handler.HelloHandler)
	// 	clientGroup.GET("/refresh_token", authMiddleware.RefreshHandler)
	// 	// adminGroup.GET("/hello", helloHandler)
	// }

	return router
}
