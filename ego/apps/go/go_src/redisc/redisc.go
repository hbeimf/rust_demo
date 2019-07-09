package redisc

// redis 连接池demo
//
import (
	"github.com/garyburd/redigo/redis"
	"time"
	// "log"
	"flag"
	"fmt"
	// "../router/ws"
)

type Redis struct {
	pool *redis.Pool
}

var (
	globalRedisHost = flag.String("globalRedisHost", "127.0.0.1:6379", "redis服务监听主机端口")
)

// 客户端连接实例
var RedisClient *Redis

func init() {
	flag.Parse()
	RedisClient = newRedisPool(*globalRedisHost, 0)
}

// http://godoc.org/github.com/garyburd/redigo/redis#Pool
func newRedisPool(server string, num int) *Redis {

	pool := &redis.Pool{
		MaxIdle:     10, //最大连接数
		IdleTimeout: time.Minute,
		Dial: func() (redis.Conn, error) {
			c, err := redis.Dial("tcp", server)
			if err != nil {
				return nil, err
			}

			_, err = c.Do("SELECT", num)
			return c, err
		},
	}

	return &Redis{pool}
}

// 字符串api start  ==================================================
func (this *Redis) RedisGet(key string) (string, error) {
	if len(key) == 0 {
		return "", nil
	}

	conn := this.pool.Get()
	defer conn.Close()

	res, err := conn.Do("GET", key)

	if err != nil {
		return "", err
	}
	if res == nil {
		return "", nil
	}

	return redis.String(res, nil)
}

func (this *Redis) RedisSet(key string, val string) {
	conn := this.pool.Get()
	defer conn.Close()

	conn.Do("SET", key, val)
}

// 设置带超时的建
func (this *Redis) RedisSetEX(key string, val string, timeout string) {
	conn := this.pool.Get()
	defer conn.Close()

	conn.Do("SET", key, val, "EX", timeout)
}

// 如果返回1设置成功
// 返回0设置失败
func (this *Redis) RedisSetNX(key string, val string) int {
	conn := this.pool.Get()
	defer conn.Close()

	r, err := conn.Do("SETNX", key, val)

	if err != nil {
		return 0
	}

	return int(r.(int64))
}

// 设置秒级过期时间
func (this *Redis) RedisEXPIRE(key string, timeout int) {
	conn := this.pool.Get()
	defer conn.Close()

	r, err := conn.Do("EXPIRE", key, timeout)

	fmt.Println(err)
	fmt.Println(r)
}

// 设置毫秒级过期时间
func (this *Redis) RedisPEXPIRE(key string, timeout int) {
	conn := this.pool.Get()
	defer conn.Close()

	r, err := conn.Do("PEXPIRE", key, timeout)

	fmt.Println(err)
	fmt.Println(r)
}

// 字符串api end ==================================================

func (this *Redis) RedisLPush(listName string, val string) {
	conn := this.pool.Get()
	defer conn.Close()

	conn.Do("LPUSH", listName, val)
}

func (this *Redis) RedisRPop(listName string) (string, error) {
	conn := this.pool.Get()
	defer conn.Close()
	res, err := conn.Do("RPOP", listName)

	if err != nil {
		return "", err
	}
	if res == nil {
		return "", nil
	}

	return redis.String(res, err)
}

// pub/sub

// // http://www.cnblogs.com/liughost/p/5008029.html
// // http://studygolang.com/articles/4542
// func (this *Redis) RedisSub(channel string) {
// 	c := this.pool.Get()
// 	psc := redis.PubSubConn{c}
// 	// psc.PSubscribe("aa*")
// 	psc.PSubscribe(channel)

// 	for {
// 		switch v := psc.Receive().(type) {
// 		case redis.Subscription:
// 			fmt.Printf("XXX %s: %s %d\n", v.Channel, v.Kind, v.Count)
// 			fmt.Println("XXX %s: %s %d\n", v.Channel, v.Kind, v.Count)
// 		case redis.Message: //单个订阅subscribe
// 			fmt.Printf("%s: XX message: %s\n", v.Channel, v.Data)
// 			fmt.Println("%s: XX message: %s\n", v.Channel, v.Data)
// 		case redis.PMessage: //模式订阅psubscribe
// 			fmt.Printf("X PMessage: %s %s %s\n", v.Pattern, v.Channel, v.Data)
// 			fmt.Println("X PMessage: %s %s %s\n", v.Pattern, v.Channel, v.Data)
// 			// 当消费到消息的时候，广播出去
// 			ws.HubInstance.Broadcast <- v.Data
// 		case error:
// 			fmt.Println("error")
// 		}
// 	}
// }

func (this *Redis) RedisPublish(channel string, msg string) error {
	conn := this.pool.Get()
	defer conn.Close()
	_, err := conn.Do("PUBLISH", channel, msg)
	return err
}
