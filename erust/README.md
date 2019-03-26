erust
=====

An OTP application

Build
-----

    $ rebar3 compile



启动多个redis节点 



 docker run -p 6379:6379 -v /redis/data:/data -d redis:3.2 redis-server --appendonly yes

hostPort:containerPort

 docker run -p 6379:6379 --name redis1 -v /redis/data:/data -d redis:3.2 redis-server --appendonly yes
 docker run -p 6380:6379 --name redis2 -v /redis/data:/data -d redis:3.2 redis-server --appendonly yes



$ docker run -p 6379:6379 --name redis1  -d redis:3.2 redis-server --appendonly yes
$ docker run -p 6380:6379 --name redis2  -d redis:3.2 redis-server --appendonly yes


搭建 redis 集群：
https://www.cnblogs.com/alex-blog/p/5651348.html


Docker 构建 redis 集群
安装docker

1、yum install docker

 

方法一：

1、 docker pull redis

2、docker run -d --name redis-1 -p 7001:6379 redis

3、docker inspect redis-1 | grep IPA

"SecondaryIPAddresses": null,
            "IPAddress": "172.17.0.2",
                    "IPAMConfig": null,
                    "IPAddress": "172.17.0.2",

$ docker inspect redis-1 | grep IPA
            "SecondaryIPAddresses": null,
            "IPAddress": "172.17.0.5",
                    "IPAMConfig": null,
                    "IPAddress": "172.17.0.5",


4、启动slave

docker run -d --name redis-2 -p 7002:6379 redis redis-server --slaveof 172.17.0.2 6379
docker run -d --name redis-3 -p 7003:6379 redis redis-server --slaveof 172.17.0.2 6379

docker run -d --name redis-2 -p 7002:6379 redis redis-server --slaveof 172.17.0.5 6379
docker run -d --name redis-3 -p 7003:6379 redis redis-server --slaveof 172.17.0.5 6379


5、验证：

redis-cli -h 127.0.0.1 -p 7001
127.0.0.1:7001> get key
"hello"
127.0.0.1:7001> exit
redis-cli -h 127.0.0.1 -p 7002
127.0.0.1:7002> get key
"hello"
127.0.0.1:7002> exit
redis-cli -h 127.0.0.1 -p 7003
127.0.0.1:7003> get key
"hello"
127.0.0.1:7003> exit


/install/redis-2.8.17/src/redis-cli -h 127.0.0.1 -p 7001
/install/redis-2.8.17/src/redis-cli -h 127.0.0.1 -p 7002
/install/redis-2.8.17/src/redis-cli -h 127.0.0.1 -p 7003

$ /install/redis-2.8.17/src/redis-cli -h 127.0.0.1 -p 7001
127.0.0.1:7001> set hello world
OK
127.0.0.1:7001> get hello
"world"
127.0.0.1:7001> exit

$ /install/redis-2.8.17/src/redis-cli -h 127.0.0.1 -p 7002
127.0.0.1:7002> get hello
"world"
127.0.0.1:7002> exit

$ /install/redis-2.8.17/src/redis-cli -h 127.0.0.1 -p 7003
127.0.0.1:7003> get hello
"world"
127.0.0.1:7003> 

