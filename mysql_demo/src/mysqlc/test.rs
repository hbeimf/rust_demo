use std::thread;

use mysqlc::init;

pub fn test() {
	let pool = init::init_pool();

	for _ in 0..10i32 {
		let pool = pool.clone();
		thread::spawn(move || {
			let connection = pool.get();
			assert!(connection.is_ok());
		});
	}
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

