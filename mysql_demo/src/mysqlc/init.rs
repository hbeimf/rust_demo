extern crate diesel;
// extern crate diesel_codegen;
extern crate r2d2;
extern crate r2d2_diesel;

use diesel::mysql::MysqlConnection;
use r2d2_diesel::ConnectionManager;

use std::thread;

pub type Pool = r2d2::Pool<ConnectionManager<MysqlConnection>>;

pub fn init_pool() -> Pool {
    let manager = ConnectionManager::<MysqlConnection>::new("mysql://root:123456@localhost:3306/test");
    r2d2::Pool::new(manager).expect("db pool")
}


pub fn test() {
	let pool = init_pool();

	for _ in 0..10i32 {
		let pool = pool.clone();
		thread::spawn(move || {
			let connection = pool.get();
			assert!(connection.is_ok());
		});
	}
}