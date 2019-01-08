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

#[macro_use] extern crate log;
// https://crates.io/crates/easy-logging

extern crate sys_config;
extern crate table;
extern crate glib;

pub mod gen_server;
pub mod action;
pub mod tcpc;
pub mod wsc;

use actix_web::server::HttpServer;
use actix_web::*;

pub fn start_server() {
	let websocket_config = sys_config::config_websocket();
	
	HttpServer::new(move || {
        let state = crate::gen_server::WsChatSessionState {

        };

        App::with_state(state)
            .resource("/ws/", |r| r.route().f(crate::gen_server::chat_route))
    }).bind(websocket_config.clone())
        .unwrap()
        .start();
}