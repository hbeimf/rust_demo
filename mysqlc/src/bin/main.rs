extern crate mysqlc;
use mysqlc::*;

// extern crate easy_logging;

// #[macro_use]
extern crate structopt;

use std::path::PathBuf;
use structopt::StructOpt;

/// A basic example
#[derive(StructOpt, Debug)]
#[structopt(name = "basic")]
struct Opt {
    // A flag, true if used in the command line. Note doc comment will
    // be used for the help message of the flag.
    // /// Activate debug mode
    // #[structopt(short = "d", long = "debug")]
    // debug: bool,

    // // The number of occurrences of the `v/verbose` flag
    // /// Verbose mode (-v, -vv, -vvv, etc.)
    // #[structopt(short = "v", long = "verbose", parse(from_occurrences))]
    // verbose: u8,

    // /// Set speed
    // #[structopt(short = "s", long = "speed", default_value = "42")]
    // speed: f64,

    /// 配置文件
    #[structopt(short = "c", long = "config", parse(from_os_str))]
    config: Vec<PathBuf>,

    // /// Number of cars
    // #[structopt(short = "c", long = "nb-cars")]
    // nb_cars: Option<i32>,

    /// admin_level to consider
    #[structopt(short = "l", long = "level")]
    level: Vec<String>,

    // /// Files to process
    // #[structopt(name = "FILE", parse(from_os_str))]
    // files: Vec<PathBuf>,
}

fn main() {
	

	 // 初始化日志功能
    easy_logging::init(module_path!(), log::Level::Debug).unwrap();
    // easy_logging::init(module_path!(), log::Level::Info).unwrap();

    let opt = Opt::from_args();
    println!("{:?}", opt);
    // debug!("Hello, world!");
    test::test();
}
