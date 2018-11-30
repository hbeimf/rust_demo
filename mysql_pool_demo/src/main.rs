extern crate easy_logging;
#[macro_use] extern crate log;
// https://crates.io/crates/easy-logging

extern crate mysql;
extern crate r2d2_mysql;
extern crate r2d2;
// use std::env;
use std::sync::Arc;
// use std::thread;
use mysql::{Opts,OptsBuilder};
use r2d2_mysql::MysqlConnectionManager;

// demo link 
// https://github.com/outersky/r2d2-mysql/blob/master/src/lib.rs

fn main() {
    // 初始化日志功能
    easy_logging::init(module_path!(), log::Level::Debug).unwrap();
    // easy_logging::init(module_path!(), log::Level::Info).unwrap();

    debug!("mysql demo");

    // let db_url =  env::var("DATABASE_URL").unwrap();
    let db_url =  "mysql://root:123456@localhost:3306/xdb";
    let opts = Opts::from_url(&db_url).unwrap();
    let builder = OptsBuilder::from_opts(opts);
    let manager = MysqlConnectionManager::new(builder);
    let pool = Arc::new(r2d2::Pool::builder().max_size(4).build(manager).unwrap());

    // let mut tasks = vec![];

    // for i in 0..3 {
    //     let pool = pool.clone();
    //     let th = thread::spawn(move || {
            let mut conn = pool.get().unwrap();
            let r = conn.query("select * from users").unwrap();
            debug!("reply: {:?}", r);

            // println!("thread {} end!" , i );
    //     });
    //     tasks.push(th);
    // }

    // for th in tasks {
    //     let _ = th.join();
    // }
}