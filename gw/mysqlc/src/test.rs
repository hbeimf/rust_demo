use std::thread;

// use mysqlc;
use pool;
use table_post;

pub fn test_bak() {
	let pool = pool::init_pool();

	for _ in 0..10i32 {
		let pool = pool.clone();
		thread::spawn(move || {
			let connection = pool.get();
			assert!(connection.is_ok());
		});
	}
}

pub fn test() {
	let pool = pool::init_pool();
	
	match pool.get() {
	            Ok(conn) => {
	            		// insert 
	            		// table_post::create_post(&conn, "titletest", "body test");
	            		table_post::select(&conn);

	            },
	            // Err(_) => Outcome::Failure((Status::ServiceUnavailable, ()))
	            _ => {
	            		println!("something else");
	            }
	}	
}

