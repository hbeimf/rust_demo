extern crate mysqlc;
use mysqlc::*;

// extern crate easy_logging;

fn main() {
	 // 初始化日志功能
    easy_logging::init(module_path!(), log::Level::Debug).unwrap();
    // easy_logging::init(module_path!(), log::Level::Info).unwrap();

    // debug!("Hello, world!");
    test::test();
}
