// #![allow(unused_variables)]
// extern crate byteorder;
// extern crate bytes;
// extern crate env_logger;
// extern crate futures;
// extern crate rand;
// extern crate serde;
// extern crate serde_json;
// extern crate tokio_codec;
// extern crate tokio_io;
// extern crate tokio_tcp;
// // #[macro_use]
// extern crate serde_derive;

// #[macro_use]
extern crate actix;
// extern crate actix_web;

// extern crate protobuf;
extern crate easy_logging;
// #[macro_use] extern crate log;
// https://crates.io/crates/easy-logging

// extern crate rusqlite;
// extern crate time;


extern crate mysqlc;
extern crate redisc;

// use actix::*;
// use actix_web::server::HttpServer;
// use actix_web::{fs, http, App, HttpResponse};
// use actix_web::*;


// extern crate sys_config;

// mod wsc;
// mod tcpc;
// mod hub;
// extern crate table;
// extern crate glib;
// mod pb;
// mod protos;
// mod wss;
// mod tcps;
extern crate tcp_server;
extern crate ws_server;


fn main() {
    
    // 初始化日志功能
    easy_logging::init(module_path!(), log::Level::Debug).unwrap();
    // easy_logging::init(module_path!(), log::Level::Info).unwrap();

    mysqlc::test::test();
    redisc::test();

    let sys = actix::System::new("websocket-example");
    tcp_server::start_server();
    ws_server::start_server();
    let _ = sys.run();
}
