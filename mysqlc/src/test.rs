// use std::thread;

// use mysqlc;
use pool;
use table_posts;
// use table_post_insert;

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
	            		table_posts::delete(&conn);
	            		table_posts::update(&conn);

	            		// table_post_insert::create_post(&conn, "titletest", "body test");
	            		let insert_instance = table_posts::Insert::new("titletest 111".to_string(), "body test 111".to_string());
	            		
	            		let _res = insert_instance.insert(&conn);


	            		
	            		table_posts::select(&conn);

	            },
	            // Err(_) => Outcome::Failure((Status::ServiceUnavailable, ()))
	            _ => {
	            		println!("something else");
	            }
	}	
}

