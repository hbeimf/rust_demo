package middleware

import (
	"time"

	"github.com/appleboy/gin-jwt"
	"github.com/gin-gonic/gin"
)

type login struct {
	Username string `form:"username" json:"username" binding:"required"`
	Password string `form:"password" json:"password" binding:"required"`
}

type User struct {
	UserName  string
	FirstName string
	LastName  string
	Uid       string
}

var identityKey = "id"

func New() (*jwt.GinJWTMiddleware, error) {

	authMiddleware, err := jwt.New(&jwt.GinJWTMiddleware{
		Realm:       "test zone",
		Key:         []byte("secret key"),
		Timeout:     time.Hour,
		MaxRefresh:  time.Hour,
		IdentityKey: identityKey,
		PayloadFunc: func(data interface{}) jwt.MapClaims {
			if v, ok := data.(*User); ok {
				// 初始化 claims
				return jwt.MapClaims{
					identityKey: v.UserName,
					"FirstName": v.FirstName,
					"LastName":  v.LastName,
					"Uid":       v.Uid,
				}
			}
			return jwt.MapClaims{}
		},
		IdentityHandler: func(c *gin.Context) interface{} {
			claims := jwt.ExtractClaims(c)
			// 初始化 user
			return &User{
				UserName:  claims["id"].(string),
				FirstName: claims["FirstName"].(string),
				LastName:  claims["LastName"].(string),
				Uid:       claims["Uid"].(string),
			}
		},
		Authenticator: func(c *gin.Context) (interface{}, error) {
			var loginVals login
			if err := c.ShouldBind(&loginVals); err != nil {
				return "", jwt.ErrMissingLoginValues
			}
			userName := loginVals.Username
			password := loginVals.Password

			// 登录校验 ， 初始化
			if (userName == "admin" && password == "admin") || (userName == "test" && password == "test") {
				return &User{
					UserName:  userName,
					LastName:  "Bo" + userName,
					FirstName: "Wu" + userName,
					Uid:       "123456" + userName,
				}, nil
			}

			return nil, jwt.ErrFailedAuthentication
		},
		Authorizator: func(data interface{}, c *gin.Context) bool {
			// 是否有权限访问校验
			return true
			// if v, ok := data.(*User); ok && v.UserName == "admin" {
			// 	return true
			// }

			// return false
		},
		Unauthorized: func(c *gin.Context, code int, message string) {
			c.JSON(code, gin.H{
				"code":    code,
				"message": message,
			})
		},
		// TokenLookup is a string in the form of "<source>:<name>" that is used
		// to extract token from the request.
		// Optional. Default value "header:Authorization".
		// Possible values:
		// - "header:<name>"
		// - "query:<name>"
		// - "cookie:<name>"
		TokenLookup: "header: Authorization, query: token, cookie: jwt",
		// TokenLookup: "query:token",
		// TokenLookup: "cookie:token",

		// TokenHeadName is a string in the header. Default value is "Bearer"
		TokenHeadName: "Bearer",

		// TimeFunc provides the current time. You can override it to use another time value. This is useful for testing or if your server uses a different time zone than your tokens.
		TimeFunc: time.Now,
	})

	return authMiddleware, err

}
