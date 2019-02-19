extern crate actix;
// extern crate mysqlc;
// extern crate redisc;
extern crate tcp_server;
// extern crate ws_server;
extern crate sys_config;
// extern crate mq_client;
extern crate glib;

extern crate flexi_logger;
#[macro_use]
extern crate log;
use flexi_logger::{Logger, detailed_format};

use std::process;

fn main() {
    
    let log_level = sys_config::config_log_level();
    let log_dir = sys_config::config_log_dir();


	Logger::with_str(log_level.clone())
        .format(detailed_format)
        .log_to_file()
        .directory(log_dir.clone())
        .rotate_over_size(200000000)
        .o_timestamp(true)
        .start_reconfigurable()
        .unwrap_or_else(|e| panic!("Logger initialization failed with {}", e));

    // error!("This is an error message");
    // warn!("This is a warning");
    debug!("================================= start server =================================!");
    debug!("log_dir: {:?}", log_dir);
    debug!("log_level: {:?}", log_level);

    
    // info!("This is an info message");
    // trace!("This is a trace message - you must not see it!");

//    mysqlc::test::test();
//    redisc::test();
    glib::http_client::test();
    glib::aes::test();

    dbg!(log_dir);

    debug!("My pid is {}", process::id());

    let sys = actix::System::new("rs-server");
    tcp_server::start_server();
    // ws_server::start_server();

    // mq_client::start_mq_client();
    let _ = sys.run();
}
