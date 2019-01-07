use schema::*;
use diesel::*;
pub use table_post_select::Post;
use diesel::expression::sql_literal::sql;
use diesel::types::{Integer};


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



#[derive(Insertable, Debug, Clone)]
#[table_name = "posts"]
pub struct InsertPost {
    title: String,
    body: String,
}




#[derive(Queryable, Debug, PartialEq, QueryableByName)]
#[table_name = "posts"]
pub struct LastInsertPost {
    #[sql_type = "Integer"]
    pub id: i32,
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

        let last_insert_id: LastInsertPost = sql("SELECT LAST_INSERT_ID()").get_result(conn).unwrap();
        println!("id: {:?}", last_insert_id);

        posts.order(id.desc()).first(conn).unwrap()
    }
       
}

