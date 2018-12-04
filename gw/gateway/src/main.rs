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
// use actix_web::{fs, http, ws, App, Error, HttpRequest, HttpResponse};
use actix_web::{fs, http, App, HttpResponse};

// use std::time::{Instant, Duration};

mod codec;
mod server;
mod session;
mod parse_package_from_tcp;
mod glib;
mod msg_proto;
mod protos;
mod handler_from_client_ws;
mod parse_package_from_ws;

fn main() {
    
    // 初始化日志功能
    easy_logging::init(module_path!(), log::Level::Debug).unwrap();
    // easy_logging::init(module_path!(), log::Level::Info).unwrap();

    mysqlc::test::test();
    redisc::test();


    // let _ = env_logger::init();
    let sys = actix::System::new("websocket-example");

    // Start chat server actor in separate thread
    let server = Arbiter::start(|_| server::ChatServer::default());

    // Start tcp server in separate thread
    let srv = server.clone();
    Arbiter::new("tcp-server").do_send::<msgs::Execute>(msgs::Execute::new(move || {
        session::TcpServer::new("127.0.0.1:12345", srv);
        Ok(())
    }));

    // Create Http server with websocket support
    HttpServer::new(move || {
        // Websocket sessions state
        // let state = WsChatSessionState {
        //     addr: server.clone(),
        // };
        let state = handler_from_client_ws::WsChatSessionState {
            addr: server.clone(),
        };

        App::with_state(state)
            // redirect to websocket.html
            .resource("/", |r| r.method(http::Method::GET).f(|_| {
                HttpResponse::Found()
                    .header("LOCATION", "/static/websocket.html")
                    .finish()
            }))
            // websocket
            // .resource("/ws/", |r| r.route().f(chat_route))
            .resource("/ws/", |r| r.route().f(handler_from_client_ws::chat_route))
            // static resources
            .handler("/static/", fs::StaticFiles::new("static/").unwrap())
    }).bind("127.0.0.1:5566")
        .unwrap()
        .start();

    debug!("Started http server: 127.0.0.1:5566");
    let _ = sys.run();
}
