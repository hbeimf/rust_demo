extern crate actix;
extern crate mysqlc;
extern crate redisc;
extern crate tcp_server;
extern crate ws_server;

extern crate flexi_logger;
#[macro_use]
extern crate log;
use flexi_logger::{Logger, detailed_format};

fn main() {
	Logger::with_str("debug")
        .format(detailed_format)
        .log_to_file()
        .directory("logs")
        .rotate_over_size(200000000000)
        .o_timestamp(true)
        .start_reconfigurable()
        .unwrap_or_else(|e| panic!("Logger initialization failed with {}", e));

    // error!("This is an error message");
    // warn!("This is a warning");
    debug!("start server!");
    
    // info!("This is an info message");
    // trace!("This is a trace message - you must not see it!");

    mysqlc::test::test();
    redisc::test();

    let sys = actix::System::new("websocket-example");
    tcp_server::start_server();
    ws_server::start_server();
    let _ = sys.run();
}
