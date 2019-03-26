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

