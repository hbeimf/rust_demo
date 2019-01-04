// CREATE TABLE `posts` (
//   `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
//   `title` varchar(300) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
//   `body` text COLLATE utf8_unicode_ci NOT NULL,
//   `published` tinyint(1) NOT NULL DEFAULT '0',
//   PRIMARY KEY (`id`)
// ) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='test';

// extern crate diesel;

use diesel::prelude::*;
// use schema::{posts};
// use schema::*;

// use schema::posts::dsl::*;
// use schema::posts::*;

use diesel::*;
// use pool;
// use diesel::sql_types::*;

// #[cfg(test)]
use diesel::mysql::Mysql;
// use diesel::mysql::Mysql; 

#[derive(Queryable, Debug, PartialEq)]
pub struct Post {
    pub id: i32,
    pub title: String,
    pub body: String,
    pub published: bool,
}

// #[derive(Insertable)]
// #[table_name = "posts"]
// pub struct NewPost<'a> {
//     pub title: &'a str,
//     pub body: &'a str,
// }



// // insert 
// pub fn create_post(conn: &MysqlConnection, title: &str, body: &str) -> Post {
//     use schema::posts::dsl::{id, posts};

//     let new_post = NewPost {
//         title: title,
//         body: body,
//     };

//     diesel::insert_into(posts)
//         .values(&new_post)
//         .execute(conn)
//         .expect("Error saving new post");

//     posts.order(id.desc()).first(conn).unwrap()
// }


// select 
// https://github.com/diesel-rs/diesel/blob/2ce0e4ea0fda474459139042247512f0c8b254cf/diesel_tests/tests/raw_sql.rs
// https://github.com/driftluo/MyBlog/blob/master/src/models/articles.rs
pub fn select(connection: &MysqlConnection) {
    // use self::schema::posts::dsl::*;
    // use schema::posts::dsl::{posts, published};

    // let results = posts
    //     .filter(published.eq(false))
    //     // .limit(5)
    //     .load::<Post>(connection)
    //     .expect("Error loading posts");

    // println!("Displaying {} posts", results.len());
    // for post in results {
    //     println!("{}", post.id);

    //     println!("{}", post.title);
    //     println!("{}", post.body);
    //     println!("-----------\n");
    //     break;
    // }

     // let rows = sql_query("SELECT id FROM posts ORDER BY id").execute(connection); 
     // println!("{:?}", rows);


    use schema::posts::dsl::*;

    println!("");
    let query = posts.select(title);
    let titles: Vec<String> = query.load(connection).unwrap();
    
    let debug = debug_query::<Mysql, _>(&query);
    debug!("query sql:===================== {:?}", debug.to_string());
    println!("{:?}", titles);

    println!("");
    debug!("===================== select id, title, body, published from posts =====================");
    let rows: Vec<(i32, String, String, bool)> = posts.load(connection).unwrap();
    println!("{:?}", rows);

    println!("");
    debug!("===================== select id, title, body, published from posts =====================");
    let rows = posts.load::<Post>(connection).unwrap();
    println!("{:?}", rows);


    // println!("");
    // debug!("===================== select id, title, body, published from posts where id = 11 =====================");
    // let row : Vec<(i32, String, String, bool)> = posts
    //         .filter(id.eq(11))
    //         .order(id.asc())
    //         .load(connection)
    //         .unwrap();
    // println!("{:?}", row);


    println!("");
    let query = posts
            .filter(id.eq(11))
            .order(id.asc());

    let debug = debug_query::<Mysql, _>(&query);
    debug!("query sql:===================== {:?}", debug.to_string());

    let rows : Vec<(i32, String, String, bool)> = query.load(connection).unwrap();
    println!("{:?}", rows);


    // println!("");
    // debug!("===================== select id, title, body, published from posts where id = 11 and title = 'titletest' =====================");    
    // let row = posts
    //         .filter(id.eq(11))
    //         .filter(title.eq("titletest"))
    //         .order(id.asc())
    //         .load::<Post>(connection)
    //         .unwrap();
    // println!("{:?}", row);



    println!("");
    let query = posts
            .filter(id.eq(11))
            .filter(title.eq("titletest"))
            .order(id.desc());

    let debug = debug_query::<Mysql, _>(&query);
    debug!("query sql:===================== {:?}", debug.to_string());

    let rows = query.load::<Post>(connection).unwrap();
    println!("{:?}", rows);




    // https://docs.rs/diesel/1.3.3/diesel/query_builder/struct.SqlQuery.html

    use diesel::types::Integer;
    use diesel::types::Text;

    let query = diesel::sql_query("SELECT id, title, body, published FROM posts WHERE id = ? AND title = ?");

    let rows = query.bind::<Integer, _>(11)
    .bind::<Text, _>("titletest")
    .execute(connection);

    println!("{:?}", rows);


    
    // println!("");
    // println!("===================== select id, title, body, published from posts where id = 11 =====================");    
    // let rows: Vec<i32> = sql_query("SELECT id FROM posts ORDER BY id").load(connection).unwrap(); 
    //  println!("{:?}", rows);


    // let query = sql_query("SELECT id FROM posts ORDER BY id");
    // let debug = debug_query::<Mysql, _>(&query);
    // debug!("query sql:===================== {:?}", debug.to_string());
    // let rows: Vec<(i32)> = query.load(connection).unwrap();


    // let users  = sql_query("SELECT id, title, body, published FROM posts ORDER BY id").load::<Post>(connection);
     
     // let rows1: std::result::Result<std::vec::Vec<(i32, String, String, bool)>, diesel::result::Error> = sql_query("SELECT id, title, body, published FROM posts").load(connection); 
     // let rows : Vec<(i32, String, String, bool)> = diesel::sql_query("SELECT id, title, body, published FROM posts").load(connection);

     // println!("{:?}", rows);
    //  let expected_users = vec![
    //     Post { id: 1, title: "Sean".into(), body: "Sean".into(), published: true },
    //     Post { id: 2, title: "Sean".into(), body: "Sean".into(), published: true }
    // ];
    // assert_eq!(Ok(expected_users), rows);

}


// query 

// pub fn query() {

//     let mysql = pool::MYSQL_INSTANCE.get(); 
//     // let conn = redis.pool.get().unwrap();
    
//     match mysql.pool.get() {
//                 Ok(conn) => {
//                         // insert 
//                         // table_post::create_post(&conn, "titletest", "body test");
//                         // table_post::select(&conn);
//                         let rows = sql_query("SELECT id FROM posts ORDER BY id").load(&conn); 
//                         // println!("rows:{:?}", rows);

//                 },
//                 // Err(_) => Outcome::Failure((Status::ServiceUnavailable, ()))
//                 _ => {
//                         println!("something else");
//                 }
//     }   

//     // let users = sql_query("SELECT * FROM users ORDER BY id")
//     //     .load(&connection);
//     // let expected_users = vec![
//     //     User { id: 1, name: "Sean".into() },
//     //     User { id: 2, name: "Tess".into() },
//     // ];
//     // assert_eq!(Ok(expected_users), users);
// }
