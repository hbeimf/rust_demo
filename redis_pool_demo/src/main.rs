extern crate easy_logging;
#[macro_use] extern crate log;
// https://crates.io/crates/easy-logging

extern crate r2d2_redis;
use std::ops::Deref;
// use std::thread;

use r2d2_redis::{r2d2, redis, RedisConnectionManager};
use r2d2_redis::redis::{Commands};

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

    // use ========================================
    let conn = pool.get().unwrap();

    // ping 
    let reply = redis::cmd("PING").query::<String>(conn.deref()).unwrap();	
    debug!("ping reply:{}", reply);

    // set 
    let _ : () = redis::cmd("SET").arg("my_key").arg(123).query(conn.deref()).unwrap();
    let val : i32 = conn.get("my_key").unwrap();
    debug!("set val:{}", val);

    let _ = conn.set::<String, String, String>("key1".to_string(), "vvvvvvvvvv".to_string());
    let val1: String = conn.get("key1").unwrap();
    debug!("set val1: {}", val1);

    let _ = conn.set::<String, i32, String>("key2".to_string(), 123456i32);
    let val1: i32 = conn.get("key2").unwrap();
    debug!("set val2: {}", val1);

    
    // hset 
	let _ = conn.hset::<String, String, String, String>("hname".to_string(), "hkeyname".to_string(), "hval123456".to_string());
    let hval: String = conn.hget("hname", "hkeyname").unwrap();
    debug!("hset hval: {}", hval);

   
    // incr 
    let n: i64 = conn.incr("counter", 1).unwrap();
    debug!("Counter increased to {}", n);

  
}

