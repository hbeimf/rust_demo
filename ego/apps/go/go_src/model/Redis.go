package model

// redis 连接池demo
//
import (
    "github.com/garyburd/redigo/redis"
    "time"
    // "log"
    "fmt"
)

type Redis struct {
    pool *redis.Pool
}



// http://godoc.org/github.com/garyburd/redigo/redis#Pool
func NewRedisPool(server string, num int) *Redis {

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








