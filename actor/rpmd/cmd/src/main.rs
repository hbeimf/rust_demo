extern crate actix;
// extern crate mysqlc;
// extern crate redisc;
extern crate tcp_server;
// extern crate ws_server;
extern crate sys_config;
// extern crate mq_client;
extern crate glib;
extern crate table;

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

    
    debug!("================================= start server =================================!");
    debug!("log_dir: {:?}", log_dir);
    debug!("log_level: {:?}", log_level);
    debug!("pid_file: {:?}", pid_file);

    Logger::with_str(log_level.clone())
        .format(detailed_format)
        .log_to_file()
        .directory(log_dir.clone())
        .rotate_over_size(200000000)
        .o_timestamp(true)
        // .start_reconfigurable()
        .start()
        .unwrap_or_else(|e| panic!("Logger initialization failed with {}", e));


    write_pid(pid_file, process::id());

    let sys = actix::System::new("rpmd");
    
    table::start_room_actor();
    tcp_server::start_server();
    
    let _ = sys.run();
}


fn write_pid(pid_file:String, pid: u32) {
    let _res = fs::write(pid_file, pid.to_string());
}
