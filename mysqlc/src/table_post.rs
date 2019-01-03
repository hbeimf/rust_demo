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
use schema::*;

// use schema::posts::dsl::*;
// use schema::posts::*;

use diesel::*;
// use pool;


#[derive(Queryable)]
pub struct Post {
    pub id: i32,
    pub title: String,
    pub body: String,
    pub published: bool,
}

#[derive(Insertable)]
#[table_name = "posts"]
pub struct NewPost<'a> {
    pub title: &'a str,
    pub body: &'a str,
}



// insert 
pub fn create_post(conn: &MysqlConnection, title: &str, body: &str) -> Post {
    use schema::posts::dsl::{id, posts};

    let new_post = NewPost {
        title: title,
        body: body,
    };

    diesel::insert_into(posts)
        .values(&new_post)
        .execute(conn)
        .expect("Error saving new post");

    posts.order(id.desc()).first(conn).unwrap()
}


// select 
// https://github.com/diesel-rs/diesel/blob/2ce0e4ea0fda474459139042247512f0c8b254cf/diesel_tests/tests/raw_sql.rs
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

     let rows = sql_query("SELECT id FROM posts ORDER BY id").execute(connection); 
     println!("{:?}", rows);
     
     // let rows = sql_query("SELECT * FROM posts").load(connection); 
     // println!("{:?}", rows);

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
