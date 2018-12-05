// https://github.com/crlf0710/singleton-rs/blob/master/src/bin/trial.rs
#[macro_use]
extern crate singleton;
use singleton::{Singleton};

// https://github.com/pinecrew/tini/blob/master/examples/read.rs
extern crate tini;
use tini::Ini;
// static INPUT: &'static str = "/erlang/rust_demo/gw/config.ini";


struct SysConfig{
    config:tini::Ini
}

impl Default for SysConfig {
    fn default() -> Self {
        let config = Ini::from_file("/erlang/rust_demo/gw/config.ini").unwrap();
        SysConfig{config:config}
    }
}

static SYS_CONFIG_INSTANCE: Singleton<SysConfig> = make_singleton!();


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


pub fn test_config() {
	config_redis();

	let config = &SYS_CONFIG_INSTANCE.get().config;

    // let config = Ini::from_file(INPUT).unwrap();

    // if you are sure
    let name1: i32 = config.get("section_one", "name1").unwrap();

    // if you aren't sure
    let name5: bool = config.get("section_one", "name5").unwrap_or(false); // non-existing key

    // check
    println!("name1: {}", name1);
    println!("name5: {}", name5);

}