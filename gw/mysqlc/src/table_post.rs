// CREATE TABLE `posts` (
//   `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '主键',
//   `title` varchar(300) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
//   `body` text COLLATE utf8_unicode_ci NOT NULL,
//   `published` tinyint(1) NOT NULL DEFAULT '0',
//   PRIMARY KEY (`id`)
// ) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci COMMENT='test';

use schema::*;
use diesel::*;
use diesel::expression::sql_literal::sql;
use diesel::result::Error;
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

    pub fn insert(&self, conn: &MysqlConnection) -> Result<Vec<Post>, Error> {
        use schema::posts::dsl::*;

        let res = diesel::insert_into(posts)
            .values(self)
            .execute(conn);

        match res {
            Ok(_v) => {
                let last_insert_res: Result<LastInsert, Error> = sql("SELECT LAST_INSERT_ID()").get_result(conn);
                match last_insert_res {
                    Ok(last_insert) => {
                        diesel::sql_query("SELECT id, title, body, published FROM posts WHERE id = ? LIMIT 1")
                             .bind::<Integer, _>(last_insert.id)
                             .load(conn)
                    }
                    Err(e) => {
                        Err(e)
                    }
                }
            },
            Err(e) => {
                Err(e)
            }
        }   
    }
}

#[derive(Debug)]
pub struct Delete {
}

impl Delete {
    pub fn new() -> Self {
        Delete {}
    }

    pub fn delete(&self, connection: &MysqlConnection) -> Result<usize, Error> {
        self.debug_sql();

        let result = diesel::sql_query("DELETE FROM posts WHERE id > 20").execute(connection);
        result

    }

    pub fn debug_sql(&self) {
        let query = diesel::sql_query("DELETE FROM posts WHERE id > 20");
        let debug = debug_query::<Mysql, _>(&query);

        println!("");
        println!("delete query sql:===================== {:?}", debug.to_string());
    }

}

#[derive(Debug)]
pub struct Update {
}

impl Update{

    pub fn new() -> Self {
        Update {}
    }

    pub fn update (&self, connection: &MysqlConnection) -> Result<usize, Error> {
        self.debug_sql();
        
        diesel::sql_query("UPDATE posts SET title = ? WHERE id = 12")
            .bind::<Text, _>("UPDATE TITLE TEST !!")
            .execute(connection) 
    }

    pub fn debug_sql(&self) {
        println!("");
        let query_debug = diesel::sql_query("UPDATE posts SET title = ? WHERE id = 12")
        .bind::<Text, _>("UPDATE TITLE TEST !!");

        let debug = debug_query::<Mysql, _>(&query_debug);
        println!("update query sql:===================== {:?}", debug.to_string());
    }
}


#[derive(Debug)]
pub struct Select {
}


impl Select {
    // add code here
    pub fn new() -> Self {
        Select {
        }
    }


    pub fn get_all(&self, connection: &MysqlConnection) -> Result<Vec<Post>, Error> {
        use schema::posts::dsl::*;
        posts.load::<Post>(connection)
    }

    pub fn get_tuple(&self, connection: &MysqlConnection) -> Result<Vec<(i32, String, String, bool)>, Error> {
        use schema::posts::dsl::*;
        posts
            .filter(id.eq(11))
            .order(id.asc())
            .load::<(i32, String, String, bool)>(connection)
    }

    pub fn get_by_sql(&self, connection: &MysqlConnection) -> Result<Vec<Post>, Error> {
        diesel::sql_query("SELECT id, title, body, published FROM posts WHERE id = ? AND title = ?")
            .bind::<Integer, _>(11)
            .bind::<Text, _>("titletest")
            .load::<Post>(connection)
        
        
    }

    pub fn select(&self, connection: &MysqlConnection) {
        let res = self.get_all(connection);
        println!("get_all:\n {:?}", res);

        let tuples = self.get_tuple(connection);
        println!("get tuples:\n {:?}", tuples);
        
        
        let res1 = self.get_by_sql(connection);
        println!("get_by_sql:\n {:?}", res1);
        
    }

}