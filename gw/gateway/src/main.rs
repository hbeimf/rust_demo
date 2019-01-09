extern crate actix;
extern crate mysqlc;
extern crate redisc;
extern crate tcp_server;
extern crate ws_server;

extern crate structopt;
use std::path::PathBuf;
use structopt::StructOpt;

extern crate flexi_logger;
#[macro_use]
extern crate log;
use flexi_logger::{Logger, detailed_format};


/// gw-server 测试服
#[derive(StructOpt, Debug)]
#[structopt(name = "mysqlc")]
struct Opt {
    /// 配置文件路径，例如: /etc/gw_server_config.ini
    #[structopt(short = "c", long = "config", parse(from_os_str))]
    config: Vec<PathBuf>,

    /// 日志等级，例如: error|warn|info|debug|trace
    #[structopt(short = "l", long = "level")]
    level: Vec<String>,
}

fn main() {
    let opt = Opt::from_args();
    println!("{:?}", opt);
    
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
