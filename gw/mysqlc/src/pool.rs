use diesel::mysql::MysqlConnection;
use r2d2_diesel::ConnectionManager;
use singleton::{Singleton};
use sys_config;

pub struct MysqlPool{
    pub pool: r2d2::Pool<ConnectionManager<MysqlConnection>>
}

impl Default for MysqlPool {
    fn default() -> Self {
        let mysql_config = sys_config::config_mysql();
		let manager = ConnectionManager::<MysqlConnection>::new(mysql_config.as_ref());
		let pool = r2d2::Pool::new(manager).expect("db pool");
		MysqlPool{pool: pool}
    }
}

pub static MYSQL_INSTANCE: Singleton<MysqlPool> = make_singleton!();
