extern crate diesel;
// extern crate diesel_codegen;
extern crate r2d2;
extern crate r2d2_diesel;

use diesel::mysql::MysqlConnection;
use r2d2_diesel::ConnectionManager;

pub type Pool = r2d2::Pool<ConnectionManager<MysqlConnection>>;


// 初始化连接池
pub fn init_pool() -> Pool {
    let manager = ConnectionManager::<MysqlConnection>::new("mysql://root:123456@localhost:3306/xdb");
    r2d2::Pool::new(manager).expect("db pool")
}
