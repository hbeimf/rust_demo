// use std::thread;

// use mysqlc;
use pool;
use table_post_select;
use table_post_insert;

// pub fn test_bak() {
// 	let pool = pool::init_pool();

// 	for _ in 0..10i32 {
// 		let pool = pool.clone();
// 		thread::spawn(move || {
// 			let connection = pool.get();
// 			assert!(connection.is_ok());
// 		});
// 	}
// }

pub fn test() {
	// let pool = pool::init_pool();

	let mysql = pool::MYSQL_INSTANCE.get(); 
    // let conn = redis.pool.get().unwrap();
	
	match mysql.pool.get() {
	            Ok(conn) => {
	            		table_post_select::delete(&conn);
	            		table_post_select::update(&conn);

	            		table_post_insert::create_post(&conn, "titletest", "body test");
	            		let insert_instance = table_post_insert::InsertPost::new("titletest 111".to_string(), "body test 111".to_string());
	            		insert_instance.insert(&conn);

	            		
	            		table_post_select::select(&conn);

	            },
	            // Err(_) => Outcome::Failure((Status::ServiceUnavailable, ()))
	            _ => {
	            		println!("something else");
	            }
	}	
}

