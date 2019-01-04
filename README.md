
依赖包查询入口： 
```
https://crates.io/
```

```
https://blog.csdn.net/mint_ying/article/details/79362312?utm_source=blogxgwz0

安装
curl https://sh.rustup.rs -sSf | sh

rustup install nightly

rustup run nightly rustc --version

rustup default nightly


$ rustc -V
rustc 1.33.0-nightly (c0bbc3927 2019-01-03)
$ cargo --version
cargo 1.33.0-nightly (0d1f1bbea 2018-12-19)
$ 

```



```

在Linux和Mac上安装Rust(稳定的二进制)的一个简单的方法，只需要在shell中运行以下命令：
$ curl -sSf https://static.rust-lang.org/rustup.sh | sh

一个简单的方法来安装测试版二进制的Rust在Linux和Mac上，只需要在shell中运行这个：
$ curl -sSf https://static.rust-lang.org/rustup.sh | sh -s -- --channel=beta
一个简单的方法来安装Rust的二进制在Linux和Mac上，只需要在shell中运行这个命令：
$ curl -sSf https://static.rust-lang.org/rustup.sh | sh -s -- --channel=nightly

```

```

[root@localhost rust_demo]# rustc -V
rustc 1.30.1 (1433507eb 2018-11-07)
[root@localhost rust_demo]# cargo --version
cargo 1.30.0 (a1a4ad372 2018-11-02)
[root@localhost rust_demo]#
```


```
[root@localhost rust_demo]# cargo -V
cargo 1.30.0 (a1a4ad372 2018-11-02)
[root@localhost rust_demo]# rustc --version
rustc 1.30.1 (1433507eb 2018-11-07)
[root@localhost rust_demo]#


```



```

[root@localhost rust_demo]# cargo -V
cargo 1.31.0-nightly (2d0863f65 2018-10-20)
[root@localhost rust_demo]# rustc --version
rustc 1.31.0-nightly (f99911a4a 2018-10-23)
[root@localhost rust_demo]# 

```


version

```
[root@localhost rust_demo]# cargo -V
cargo 0.21.0 (5b4b8b2ae 2017-08-12)
[root@localhost rust_demo]# rustc --version
rustc 1.20.0 (f3d6973f4 2017-08-27)
[root@localhost rust_demo]# 
```

# rust_demo


cook book

https://rustcc.gitbooks.io/rustprimer/content/quickstart/rust-travel.html

en 

https://doc.rust-lang.org/book/second-edition/



cargo doc 

https://rustcc.gitbooks.io/rustprimer/content/cargo-projects-manager/cargo-projects-manager.html

=============================

http://www.csdn.net/article/1970-01-01/2826359

7. Mio/eventual/coio-rs – 异步库/异步io

```
https://github.com/carllerche/mio
https://github.com/carllerche/eventual
https://github.com/zonyitoo/coio-rs
```


=================================
doc 

http://wiki.jikexueyuan.com/project/rust/guessing-game.html



==================================
tokio, Linkerd-tcp
```

https://buoyant.io/2017/03/29/introducing-linkerd-tcp/

https://github.com/linkerd/linkerd-tcp


https://github.com/tokio-rs

https://github.com/tokio-rs/tokio-proto

tokio-core + tokio-io 

https://github.com/zonyitoo/tokio_kcp
```

===================================
http 

https://github.com/sappworks/sapper

https://rocket.rs/

======================================

orm 
http://diesel.rs/

https://github.com/diesel-rs/diesel

=====================================
CockroachDB

tidb

http://geek.csdn.net/news/detail/52122
http://www.techweb.com.cn/network/system/2017-06-24/2540403.shtml

Codis 
http://www.cnblogs.com/xuanzhi201111/p/4425194.html

https://github.com/blacktear23/documents/blob/master/TiDB-OLAP-Optimization.md

OceanBase

====================================

lifetime doc 

http://blog.csdn.net/renhuailin/article/details/46471233

