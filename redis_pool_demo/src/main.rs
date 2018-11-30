extern crate easy_logging;
#[macro_use] extern crate log;
// https://crates.io/crates/easy-logging

extern crate r2d2_redis;
use std::ops::Deref;
// use std::thread;

use r2d2_redis::{r2d2, redis, RedisConnectionManager};
use r2d2_redis::redis::Commands;

// https://docs.rs/redis/0.9.1/redis/
fn main() {
	// 初始化日志功能
    easy_logging::init(module_path!(), log::Level::Debug).unwrap();
    // easy_logging::init(module_path!(), log::Level::Info).unwrap();

    debug!("redis demo");

    let manager = RedisConnectionManager::new("redis://localhost:6379").unwrap();
    let pool = r2d2::Pool::builder()
        .build(manager)
        .unwrap();

    for _i in 0..10i32 {
        let conn = pool.get().unwrap();
        // conn.set("key1", 123i32).unwrap();
        let reply = redis::cmd("PING").query::<String>(conn.deref()).unwrap();
        let _ : () = redis::cmd("SET").arg("my_key").arg(123).query(conn.deref()).unwrap();
        let val : i32 = conn.get("my_key").unwrap();

        debug!("reply:{}, val:{}", reply, val);

        let n: i64 = conn.incr("counter", 1).unwrap();
        debug!("Counter increased to {}", n);
    }
  
}

