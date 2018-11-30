extern crate easy_logging;
#[macro_use] extern crate log;
// https://crates.io/crates/easy-logging

extern crate r2d2_redis;


use r2d2_redis::{r2d2, RedisConnectionManager};
use r2d2_redis::redis::Commands;

// use bincode::rustc_serialize::{encode, decode};
// // use redis::Commands;
// use r2d2_redis::redis::RedisResult;
// use r2d2_redis::redis::ToRedisArgs;
// use r2d2_redis::redis::FromRedisValue;
// use r2d2_redis::redis::RedisError;
// use r2d2_redis::redis::Value;

fn main() {
	// 初始化日志功能
    easy_logging::init(module_path!(), log::Level::Debug).unwrap();
    // easy_logging::init(module_path!(), log::Level::Info).unwrap();

    debug!("redis demo");

    let manager = RedisConnectionManager::new("redis://localhost:6379").unwrap();
    let pool = r2d2::Pool::builder()
        .build(manager)
        .unwrap();


	let conn = pool.get().unwrap();
    let n: i64 = conn.incr("counter", 1).unwrap();
    debug!("Counter increased to {}", n);


    // conn.set("my_key", EncodeWrapper(42) );

    let res: u64 = conn.get("counter").unwrap();
    debug!("get {}", res);
     
}

