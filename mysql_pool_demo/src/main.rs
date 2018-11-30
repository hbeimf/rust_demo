extern crate mysql;
extern crate r2d2_mysql;
extern crate r2d2;
// use std::env;
use std::sync::Arc;
use std::thread;
use mysql::{Opts,OptsBuilder};
use r2d2_mysql::MysqlConnectionManager;

// demo link 
// https://github.com/outersky/r2d2-mysql/blob/master/src/lib.rs

fn main() {
    // let db_url =  env::var("DATABASE_URL").unwrap();
    let db_url =  "mysql://root:123456@localhost:3306/xdb";
    let opts = Opts::from_url(&db_url).unwrap();
    let builder = OptsBuilder::from_opts(opts);
    let manager = MysqlConnectionManager::new(builder);
    let pool = Arc::new(r2d2::Pool::builder().max_size(4).build(manager).unwrap());

    let mut tasks = vec![];

    for i in 0..3 {
        let pool = pool.clone();
        let th = thread::spawn(move || {
            let mut conn = pool.get().unwrap();
            conn.query("select user()").unwrap();
            println!("thread {} end!" , i );
        });
        tasks.push(th);
    }

    for th in tasks {
        let _ = th.join();
    }
}