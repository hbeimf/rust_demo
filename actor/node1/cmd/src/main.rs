extern crate actix;
// extern crate mysqlc;
// extern crate redisc;
extern crate tcp_server;
// extern crate ws_server;
extern crate sys_config;
// extern crate mq_client;
extern crate glib;
extern crate rpmd;
extern crate rpmd_broker;


extern crate flexi_logger;
#[macro_use]
extern crate log;
use flexi_logger::{Logger, detailed_format};

use std::process;
use std::fs;

fn main() {
    
    let log_level = sys_config::config_log_level();
    let log_dir = sys_config::config_log_dir();
    let pid_file = sys_config::config_pid_file();


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
    debug!("pid_file: {:?}", pid_file);
    // dbg!(process::id());
    write_pid(pid_file, process::id());

    // info!("This is an info message");
    // trace!("This is a trace message - you must not see it!");

//    mysqlc::test::test();
//    redisc::test();
    // glib::http_client::test();
//     glib::aes::test();

    // dbg!(log_dir);

    let sys = actix::System::new("rs-server");
    tcp_server::start_server();
    // ws_server::start_server();

    // mq_client::start_mq_client();
    rpmd::start();
    rpmd_broker::start();

    let _ = sys.run();
}


fn write_pid(pid_file:String, pid: u32) {
        // dbg!(pid_file.clone());
        // dbg!(pid);
        let _res = fs::write(pid_file, pid.to_string());
        // dbg!(res);
}
