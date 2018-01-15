// extern crate r2d2_mysql;
// extern crate r2d2;
 
// use std::sync::Arc;
// use std::thread;

extern crate diesel;
// extern crate diesel_codegen;

extern crate r2d2;
extern crate r2d2_diesel;

// use r2d2;
//use diesel::mysql::MysqlConnection;
use diesel::mysql::*;
use r2d2_diesel::ConnectionManager;


pub type Pool = r2d2::Pool<ConnectionManager<MysqlConnection>>;

// pub const DATABASE_FILE: &'static str = env!("DATABASE_URL");

pub fn init_pool() -> Pool {
    // let config = r2d2::Config::default();
    let manager = ConnectionManager::<MysqlConnection>::new("mysql://root:123456@localhost:3306/test");
    r2d2::Pool::new(manager).expect("db pool")
}


fn main() {

}



// extern crate r2d2_mysql;
// extern crate r2d2;

// use std::sync::Arc;
// use std::thread;

// fn main() {
//     let db_url =  "mysql://root:12345678@localhost:3306/test";
//     let config = r2d2::config::Builder::new().pool_size(5).build();   // r2d2::Config::default()
//     let manager = r2d2_mysql::MysqlConnectionManager::new(db_url).unwrap();
//     let pool = Arc::new(r2d2::Pool::new(config, manager).unwrap());

//     let mut tasks = vec![];

//     for i in 0..3 {
//         let pool = pool.clone();
//         let th = thread::spawn(move || {
//             let mut conn = pool.get().unwrap();
//             conn.query("select user()").unwrap();
//             println!("thread {} end!" , i );
//         });
//         tasks.push(th);
//     }

//     for th in tasks {
//         let _ = th.join();
//     }
// }