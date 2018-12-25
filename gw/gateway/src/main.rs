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
#[macro_use]
extern crate serde_derive;

#[macro_use]
extern crate actix;
extern crate actix_web;

extern crate protobuf;
extern crate easy_logging;
#[macro_use] extern crate log;
// https://crates.io/crates/easy-logging

extern crate mysqlc;
extern crate redisc;

use actix::*;
use actix_web::server::HttpServer;
// use actix_web::{fs, http, App, HttpResponse};
use actix_web::*;


extern crate sys_config;

mod wsc;
mod tcpc;
mod hub;
mod glib;
mod pb;
mod protos;
mod wss;
mod tcps;

fn main() {
    
    // 初始化日志功能
    easy_logging::init(module_path!(), log::Level::Debug).unwrap();
    // easy_logging::init(module_path!(), log::Level::Info).unwrap();

    mysqlc::test::test();
    redisc::test();


    let websocket_config = sys_config::config_websocket();
    let tcp_config = sys_config::config_tcp();


    // let _ = env_logger::init();
    let sys = actix::System::new("websocket-example");
    // wsc::test();

    // // Start chat server actor in separate thread
    // let server = Arbiter::start(|_| hub::gen_server::RoomActor::default());

    // Start tcp server in separate thread
    // let srv = server.clone();
    Arbiter::new("tcp-server").do_send::<msgs::Execute>(msgs::Execute::new(move || {
        tcps::gen_server::TcpServer::new(tcp_config.as_ref());
        Ok(())
    }));

    // Create Http server with websocket support
    HttpServer::new(move || {
        // Websocket sessions state
        // let state = WsChatSessionState {
        //     addr: server.clone(),
        // };
        let state = wss::gen_server::WsChatSessionState {
            // addr: server.clone(),
        };

        App::with_state(state)
            // // redirect to websocket.html
            // .resource("/", |r| r.method(http::Method::GET).f(|_| {
            //     HttpResponse::Found()
            //         .header("LOCATION", "/static/websocket.html")
            //         .finish()
            // }))
            // websocket
            // .resource("/ws/", |r| r.route().f(chat_route))
            .resource("/ws/", |r| r.route().f(wss::gen_server::chat_route))
            // // static resources
            // .handler("/static/", fs::StaticFiles::new("static/").unwrap())
    }).bind(websocket_config.clone())
        .unwrap()
        .start();

    // debug!(websocket_config.as_ref());
    debug!("Started http server: {}", websocket_config.clone());
    let _ = sys.run();
}
