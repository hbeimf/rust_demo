// extern crate easy_logging;
// #[macro_use] extern crate log;
// // https://crates.io/crates/easy-logging

extern crate r2d2_redis;
use std::ops::Deref;
// use std::thread;

use r2d2_redis::{r2d2, redis, RedisConnectionManager};
use r2d2_redis::redis::{Commands};


// https://github.com/crlf0710/singleton-rs/blob/master/src/bin/trial.rs
#[macro_use]
extern crate singleton;
use singleton::{Singleton};

// // https://github.com/pinecrew/tini/blob/master/examples/read.rs
// extern crate tini;
// use tini::Ini;
// static INPUT: &'static str = "/erlang/rust_demo/gw/config.ini";

extern crate sys_config;

struct RedisPool{
    pool:r2d2_redis::r2d2::Pool<r2d2_redis::RedisConnectionManager>
}

impl Default for RedisPool {
    fn default() -> Self {
        let redis_config = sys_config::config_redis();
        let manager = RedisConnectionManager::new(redis_config.as_ref()).unwrap();
        // let manager = RedisConnectionManager::new("redis://localhost:6379").unwrap();

        let pool = r2d2::Pool::builder().build(manager).unwrap();
        RedisPool{pool:pool}
    }
}

static REDIS_INSTANCE: Singleton<RedisPool> = make_singleton!();


// pub fn test_config() {
//     let config = Ini::from_file(INPUT).unwrap();

//     // if you are sure
//     let name1: i32 = config.get("section_one", "name1").unwrap();

//     // if you aren't sure
//     let name5: bool = config.get("section_one", "name5").unwrap_or(false); // non-existing key

//     // check
//     println!("name1: {}", name1);
//     println!("name5: {}", name5);

// }

pub fn test_pool() {
    let redis = REDIS_INSTANCE.get(); 
    let conn = redis.pool.get().unwrap();

    let reply = redis::cmd("PING").query::<String>(conn.deref()).unwrap();  
    println!("ping reply:{}", reply);

}



pub fn ping() {
    let conn = REDIS_INSTANCE.get().pool.get().unwrap();

    // ping 
    let reply = redis::cmd("PING").query::<String>(conn.deref()).unwrap();  
    println!("ping reply:{}", reply); 
}


pub fn set() {
    let conn = REDIS_INSTANCE.get().pool.get().unwrap();

    let _ : () = redis::cmd("SET").arg("my_key").arg(123).query(conn.deref()).unwrap();
    let val : i32 = conn.get("my_key").unwrap();
    println!("set val:{}", val);

    let _ = conn.set::<String, String, String>("key1".to_string(), "vvvvvvvvvv".to_string());
    let val1: String = conn.get("key1").unwrap();
    println!("set val1: {}", val1);

    let _ = conn.set::<String, i32, String>("key2".to_string(), 123456i32);
    let val1: i32 = conn.get("key2").unwrap();
    println!("set val2: {}", val1);

}

pub fn hset() {
    let conn = REDIS_INSTANCE.get().pool.get().unwrap();

    let _ = conn.hset::<String, String, String, String>("hname".to_string(), "hkeyname".to_string(), "hval123456".to_string());
    let hval: String = conn.hget("hname", "hkeyname").unwrap();
    println!("hset hval: {}", hval);
}


pub fn incr() {
    let conn = REDIS_INSTANCE.get().pool.get().unwrap();
    let n: i64 = conn.incr("counter", 1).unwrap();
    println!("Counter increased to {}", n);
    
}


// https://docs.rs/redis/0.9.1/redis/
pub fn test() {
    // sys_config::test_config();
	// // 初始化日志功能
 //    easy_logging::init(module_path!(), log::Level::println);
 //    // easy_logging::init(module_path!(), log::Level::Info).unwrap();

 //    println!("redis demo");

    // let manager = RedisConnectionManager::new("redis://localhost:6379").unwrap();
    // let pool = r2d2::Pool::builder()
    //     .build(manager)
    //     .unwrap();

    // // use ========================================
    // let conn = pool.get().unwrap();

    // let redis = REDIS_INSTANCE.get(); 
    // let conn = REDIS_INSTANCE.get().pool.get().unwrap();


    // ping 
    // let reply = redis::cmd("PING").query::<String>(conn.deref()).unwrap();	
    // println!("ping reply:{}", reply);
    ping();

    // set 
    // let _ : () = redis::cmd("SET").arg("my_key").arg(123).query(conn.deref()).unwrap();
    // let val : i32 = conn.get("my_key").unwrap();
    // println!("set val:{}", val);

    // let _ = conn.set::<String, String, String>("key1".to_string(), "vvvvvvvvvv".to_string());
    // let val1: String = conn.get("key1").unwrap();
    // println!("set val1: {}", val1);

    // let _ = conn.set::<String, i32, String>("key2".to_string(), 123456i32);
    // let val1: i32 = conn.get("key2").unwrap();
    // println!("set val2: {}", val1);
    set();
    
    // hset 
	// let _ = conn.hset::<String, String, String, String>("hname".to_string(), "hkeyname".to_string(), "hval123456".to_string());
 //    let hval: String = conn.hget("hname", "hkeyname").unwrap();
 //    println!("hset hval: {}", hval);
    hset();
   
    // incr 
    // let n: i64 = conn.incr("counter", 1).unwrap();
    // println!("Counter increased to {}", n);

    incr();
  
}

