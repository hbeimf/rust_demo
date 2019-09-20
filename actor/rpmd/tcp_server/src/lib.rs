#![allow(unused_variables)]
extern crate byteorder;
extern crate bytes;
extern crate env_logger;
extern crate futures;
extern crate rand;
extern crate serde;
extern crate serde_json;
extern crate tokio_codec;
extern crate tokio_io;
extern crate tokio_tcp;
// #[macro_use]
extern crate serde_derive;

// #[macro_use]
extern crate actix;
extern crate actix_web;
extern crate sys_config;
extern crate table;
extern crate glib;
// extern crate tcp_client;

pub mod gen_server;
pub mod parse_package_from_tcp;
pub mod cmd;

use actix::*;

#[macro_use]
extern crate log;

pub fn start_server() {
	let tcp_config = sys_config::config_tcp();
	warn!("start server: {}", tcp_config);

	Arbiter::new("tcp-server").do_send::<msgs::Execute>(msgs::Execute::new(move || {
        		crate::gen_server::TcpServer::new(tcp_config.as_ref());
        		Ok(())
	}));
}