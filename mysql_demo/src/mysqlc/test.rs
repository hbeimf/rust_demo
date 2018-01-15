use std::thread;

use mysqlc;
use mysqlc::init;

pub fn test_bak() {
	let pool = init::init_pool();

	for _ in 0..10i32 {
		let pool = pool.clone();
		thread::spawn(move || {
			let connection = pool.get();
			assert!(connection.is_ok());
		});
	}
}

pub fn test() {
	let pool = init::init_pool();
	// let connection = pool.get();
	// assert!(connection.is_ok());

	match pool.get() {
	            Ok(conn) => {
	            		mysqlc::create_post(&conn, "titletest", "body test");
	            },
	            // Err(_) => Outcome::Failure((Status::ServiceUnavailable, ()))
	            _ => {
	            		println!("something else");
	            }
	}

	// match connection {
	// 	Some(conn) => {
	// 		mysqlc::create_post(conn, "titletest", "body test");
	// 	},
	// 	_ => {
	// 		println!("something else");
	// 	}
	// }

	
}






// pub fn select() {


// }

// extern crate diesel;
// // extern crate mysqlc;

// use mysqlc::*;
// use mysqlc::models::*;
// use diesel::prelude::*;

// fn test() {
//     use mysqlc::schema::posts::dsl::*;

//     let pool = init::init_pool();
//     let connection = pool.get();

//     // let connection = establish_connection();


//     let results = posts
//         .filter(published.eq(true))
//         .limit(5)
//         .load::<Post>(&connection)
//         .expect("Error loading posts");

//     println!("Displaying {} posts", results.len());
//     for post in results {
//         println!("{}", post.title);
//         println!("-----------\n");
//         println!("{}", post.body);
//     }
// }






// pub fn test() {
// 	use mysqlc::schema::posts::dsl::*;

// 	let pool = init_pool();

// 	for _ in 0..10i32 {
// 		let pool = pool.clone();
// 		thread::spawn(move || {
// 			let connection = pool.get();
// 			assert!(connection.is_ok());
// 			let results = posts
// 			        .filter(published.eq(true))
// 			        .limit(5)
// 			        .load::<Post>(&connection)
// 			        .expect("Error loading posts");

// 			 println!("Displaying {} posts", results.len());
// 			    for post in results {
// 			        println!("{}", post.title);
// 			        println!("-----------\n");
// 			        println!("{}", post.body);
// 			    }
// 		});
// 	}
// }

