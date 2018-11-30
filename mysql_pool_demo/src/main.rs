extern crate r2d2_mysql;
extern crate r2d2;

use std::sync::Arc;
use std::thread;

fn main() {
    let db_url =  "mysql://root:123456@localhost:3306/xdb";
    let config = r2d2::config::Builder::new().pool_size(5).build();   // r2d2::Config::default()
    let manager = r2d2_mysql::MysqlConnectionManager::new(db_url).unwrap();
    let pool = Arc::new(r2d2::Pool::new(config, manager).unwrap());

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