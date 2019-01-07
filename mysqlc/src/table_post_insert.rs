// CREATE TABLE `posts` (
//   `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
//   `title` varchar(300) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
//   `body` text COLLATE utf8_unicode_ci NOT NULL,
//   `published` tinyint(1) NOT NULL DEFAULT '0',
//   PRIMARY KEY (`id`)
// ) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='test';


use schema::*;
use diesel::*;

// use diesel::prelude::*;
// use schema::posts;

// pub use table_post_select::Post
// use diesel::mysql::Mysql;
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



#[derive(Insertable, Debug, Clone)]
#[table_name = "posts"]
pub struct InsertPost {
    title: String,
    body: String,
}

impl InsertPost {
    pub fn new(title: String, body: String) -> Self {
        InsertPost {
            title,
            body,
        }
    }

    pub fn insert(&self, conn: &MysqlConnection) -> Post {
        use schema::posts::dsl::{id, posts};

        diesel::insert_into(posts)
            .values(self)
            .execute(conn)
            .unwrap();
        posts.order(id.desc()).first(conn).unwrap()
    }

    // fn insert(&self, conn: &MysqlConnection) -> Post {
    //     diesel::insert_into(posts::table)
    //         .values(self)
    //         .get_result::<Post>(conn)
    //         .unwrap()
    // }
       
}

