// CREATE TABLE `posts` (
//   `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
//   `title` varchar(300) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
//   `body` text COLLATE utf8_unicode_ci NOT NULL,
//   `published` tinyint(1) NOT NULL DEFAULT '0',
//   PRIMARY KEY (`id`)
// ) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='test';

use schema::*;
use diesel::expression::sql_literal::sql;

use diesel::prelude::*;
use diesel::*;
use diesel::mysql::Mysql;
use diesel::types::{Integer, Text, Bool};

#[derive(Queryable, Debug, PartialEq, QueryableByName)]
#[table_name = "posts"]
pub struct Post {
    #[sql_type = "Integer"]
    pub id: i32,
    #[sql_type = "Text"]
    pub title: String,
    #[sql_type = "Text"]
    pub body: String,
    #[sql_type = "Bool"]
    pub published: bool,
}



#[derive(Insertable, Debug, Clone)]
#[table_name = "posts"]
pub struct Insert {
    title: String,
    body: String,
}

#[derive(Queryable, Debug, PartialEq, QueryableByName)]
#[table_name = "posts"]
pub struct LastInsert {
    #[sql_type = "Integer"]
    pub id: i32,
}

impl Insert {
    pub fn new(title_str: String, body_str: String) -> Self {
        Insert {
            title: title_str,
            body: body_str,
        }
    }

    pub fn insert(&self, conn: &MysqlConnection) -> Post {
        use schema::posts::dsl::*;

        diesel::insert_into(posts)
            .values(self)
            .execute(conn)
            .unwrap();

        let last_insert: LastInsert = sql("SELECT LAST_INSERT_ID()").get_result(conn).unwrap();
        println!("id: {:?}", last_insert.id);

        println!("");
        let query = diesel::sql_query("SELECT id, title, body, published FROM posts WHERE id = ? LIMIT 1")
         .bind::<Integer, _>(last_insert.id);
        let rows: Vec<Post> = query.load(conn).unwrap();

        debug!("{:?}", rows);

        posts.order(id.desc()).first(conn).unwrap() 
    }
       
}

// pub fn insert() {

// }

pub fn delete(connection: &MysqlConnection) {
    println!("");
    let query = diesel::sql_query("DELETE FROM posts WHERE id > 20");

    let debug = debug_query::<Mysql, _>(&query);
    debug!("delete query sql:===================== {:?}", debug.to_string());


    let query1 = diesel::sql_query("DELETE FROM posts WHERE id > 20");
    let result = query1.execute(connection);

    println!("delete: {:?}", result);

}

pub fn update (connection: &MysqlConnection) {
    println!("");
    let query_debug = diesel::sql_query("UPDATE posts SET title = ? WHERE id = 12")
    .bind::<Text, _>("UPDATE TITLE TEST !!");

    let debug = debug_query::<Mysql, _>(&query_debug);
    debug!("update query sql:===================== {:?}", debug.to_string());

    let result = diesel::sql_query("UPDATE posts SET title = ? WHERE id = 12")
    .bind::<Text, _>("UPDATE TITLE TEST !!").execute(connection);

    println!("update: {:?}", result);   
}

// select 
// https://github.com/diesel-rs/diesel/blob/2ce0e4ea0fda474459139042247512f0c8b254cf/diesel_tests/tests/raw_sql.rs
// https://github.com/driftluo/MyBlog/blob/master/src/models/articles.rs
// https://github.com/yinyanlv/partner/blob/master/src/models/work_record.rs
pub fn select(connection: &MysqlConnection) {
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
    println!("");
    let query = diesel::sql_query("SELECT id, title, body, published FROM posts WHERE id = ? AND title = ?");

    let rows = query.bind::<Integer, _>(11)
    .bind::<Text, _>("titletest")
    .execute(connection);

    println!("{:?}", rows);



    println!("");
    let query = diesel::sql_query("SELECT id, title, body, published FROM posts WHERE id = ? AND title = ?")
     .bind::<Integer, _>(11)
    .bind::<Text, _>("titletest");

    // let debug = debug_query::<Mysql, _>(&query);
    // debug!("query sql:===================== {:?}", debug.to_string());
    
    let rows: Vec<Post> = query.load(connection).unwrap();
    println!("sql_query: {:?}", rows);
    
    

}
