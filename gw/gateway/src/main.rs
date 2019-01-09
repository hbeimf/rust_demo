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

use std::path::Path;

/// rs-server 试验服
#[derive(StructOpt, Debug)]
#[structopt(name = "rs-server")]
struct Opt {
    /// 配置文件路径，例如: /etc/gw_server_config.ini
    #[structopt(short = "c", long = "config", parse(from_os_str))]
    config: Vec<PathBuf>,

    /// 日志存放目录，例如: /erlang/rust_demo/
    #[structopt(short = "d", long = "dir")]
    dir: Vec<String>,

    /// 日志等级，例如: error|warn|info|debug|trace
    #[structopt(short = "l", long = "level")]
    level: Vec<String>,
}

fn main() {
    let opt = Opt::from_args();
    // println!("{:?}", opt);
    
    // config
    let mut config: PathBuf = PathBuf::from(r"/erlang/rust_demo/gw/default_config.ini");
    if ! opt.config.is_empty() {
        if let Some(conf) = opt.config.get(0) {
            if conf.is_file() {
                config = (*conf).clone();
            }
        }
    }

    if let Some(config_dir) = config.to_str(){
        let con: String = config_dir.to_string();
        println!("config_dir :{:?}", con);
    }

    // log dir 
    let mut log_dir: String = "/erlang/rust_demo/gw/logs/".to_string();
    if ! opt.dir.is_empty() {
        if let Some(dir) = opt.dir.get(0) {
            if Path::new(dir).is_dir() {
                log_dir = (*dir).clone();
            }
        }
    }
    // println!("log_dir: {:?}", log_dir);
    // log level
    let mut log_level: String = "debug".to_string();
    if ! opt.level.is_empty() {
        if let Some(level) = opt.dir.get(0) {
            let levels = ["error", "warn", "info", "debug", "trace"];
            if levels.contains(&level.as_str()) {
                log_level = (*level).clone();
            }
        }
    }
    // println!("log_level: {:?}", log_level);


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

    // mysqlc::test::test();
    // redisc::test();

    let sys = actix::System::new("rs-server");
    tcp_server::start_server();
    ws_server::start_server();
    let _ = sys.run();
}
