#[macro_use]
extern crate diesel;
// extern crate diesel_codegen;
extern crate r2d2;
extern crate r2d2_diesel;

// pub mod mysqlc;
// extern crate sys_config;

// https://github.com/crlf0710/singleton-rs/blob/master/src/bin/trial.rs
#[macro_use]
extern crate singleton;
// use singleton::{Singleton};

pub mod test;
pub mod pool;
pub mod schema;
pub mod table_post;
pub mod table_post_insert;


extern crate easy_logging;
#[macro_use] extern crate log;

fn main() {
	 // 初始化日志功能
    easy_logging::init(module_path!(), log::Level::Debug).unwrap();
    // easy_logging::init(module_path!(), log::Level::Info).unwrap();

    // debug!("Hello, world!");
    test::test();
}
