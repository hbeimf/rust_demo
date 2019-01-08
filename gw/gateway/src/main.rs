// #[macro_use]
extern crate actix;
extern crate easy_logging;
// #[macro_use] extern crate log;
// https://crates.io/crates/easy-logging

extern crate mysqlc;
extern crate redisc;
extern crate tcp_server;
extern crate ws_server;


fn main() {

    // 初始化日志功能
    // easy_logging::init(module_path!(), log::Level::Debug).unwrap();
    // easy_logging::init(module_path!(), log::Level::Info).unwrap();

    mysqlc::test::test();
    redisc::test();

    let sys = actix::System::new("websocket-example");
    tcp_server::start_server();
    ws_server::start_server();
    let _ = sys.run();
}
