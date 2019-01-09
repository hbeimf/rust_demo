extern crate actix;
extern crate mysqlc;
extern crate redisc;
extern crate tcp_server;
extern crate ws_server;
extern crate sys_config;


extern crate flexi_logger;
#[macro_use]
extern crate log;
use flexi_logger::{Logger, detailed_format};



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

    mysqlc::test::test();
    redisc::test();

    let sys = actix::System::new("rs-server");
    tcp_server::start_server();
    ws_server::start_server();
    let _ = sys.run();
}
