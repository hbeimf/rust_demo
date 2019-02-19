#[macro_use]
extern crate singleton;
use singleton::{Singleton};

extern crate tini;
use tini::Ini;

extern crate structopt;
use std::path::PathBuf;
use structopt::StructOpt;
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

    /// pid 存放文件 rs.pid
    #[structopt(short = "p", long = "pid")]
    pid_file: Vec<String>,
}

struct SysConfig{
    config: tini::Ini,
    config_dir: String,
    log_dir: String,
    log_level: String, 
    pid_file: String,
}

impl Default for SysConfig {
    fn default() -> Self {
        let opt = Opt::from_args();
        println!("{:?}", opt);
        
        // config
        let mut ini_config_file: PathBuf = PathBuf::from(r"/erlang/rust_demo/gw/default_config.ini");
        if ! opt.config.is_empty() {
            if let Some(conf) = opt.config.get(0) {
                if conf.is_file() {
                    ini_config_file = (*conf).clone();
                }
            }
        }

        let mut ini_config: String = "/erlang/rust_demo/gw/default_config.ini".to_string();
        if let Some(config_dir) = ini_config_file.to_str(){
            ini_config = config_dir.to_string();
            // println!("config_dir ss :{:?}", con);
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

        // rs.pid
        let mut pid_file: String = "/erlang/rust_demo/gw/logs/rs.pid".to_string();
        if ! opt.pid_file.is_empty() {
            if let Some(dir) = opt.pid_file.get(0) {
                if Path::new(dir).is_dir() {
                    pid_file = (*dir).clone();
                }
            }
        }

        let config = Ini::from_file(&ini_config).unwrap();
        SysConfig{config:config, config_dir: ini_config, log_dir:log_dir, log_level:log_level, pid_file:pid_file}
    }
}

static SYS_CONFIG_INSTANCE: Singleton<SysConfig> = make_singleton!();

pub fn config_ini_dir() -> String {
    let config = &SYS_CONFIG_INSTANCE.get().config_dir;
    config.to_string()
}

pub fn config_log_dir() -> String {
    let config = &SYS_CONFIG_INSTANCE.get().log_dir;
    config.to_string()
}

pub fn config_pid_file() -> String {
    let config = &SYS_CONFIG_INSTANCE.get().pid_file;
    config.to_string()
}

pub fn config_log_level() -> String {
    let config = &SYS_CONFIG_INSTANCE.get().log_level;
    config.to_string()
}

pub fn config_redis() -> String {
	let config = &SYS_CONFIG_INSTANCE.get().config;
	let redis_config: String = config.get("redis", "config").unwrap();
	redis_config
}

pub fn config_mysql() -> String {
	let config = &SYS_CONFIG_INSTANCE.get().config;
	let mysql_config: String = config.get("mysql", "config").unwrap();
	mysql_config
}

pub fn config_websocket() -> String {
    let config = &SYS_CONFIG_INSTANCE.get().config;
    let mysql_config: String = config.get("websocket", "config").unwrap();
    mysql_config
}

pub fn config_tcp() -> String {
    let config = &SYS_CONFIG_INSTANCE.get().config;
    let mysql_config: String = config.get("tcp", "config").unwrap();
    mysql_config
}

pub fn config_rabbit() -> String {
    let config = &SYS_CONFIG_INSTANCE.get().config;
    let rabbit_config: String = config.get("rabbit", "config").unwrap();
    rabbit_config
}


pub fn test_config() {
	config_redis();

	let config = &SYS_CONFIG_INSTANCE.get().config;

    // if you are sure
    let name1: i32 = config.get("section_one", "name1").unwrap();

    // if you aren't sure
    let name5: bool = config.get("section_one", "name5").unwrap_or(false); // non-existing key

    // check
    println!("name1: {}", name1);
    println!("name5: {}", name5);

}