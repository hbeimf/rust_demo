#![allow(unused_variables)]
extern crate byteorder;
extern crate bytes;
extern crate env_logger;
extern crate futures;
extern crate rand;
extern crate serde;
extern crate serde_json;
extern crate tokio_core;
extern crate tokio_io;

extern crate actix;
extern crate actix_web;

extern crate protobuf;
mod server;
mod protos;
mod glib;
mod handler_from_client;

use actix::*;
use actix_web::server::HttpServer;
use actix_web::{fs, http, App,  HttpResponse};

fn main() {
    // glib::test();
    let _ = env_logger::init();
    let sys = actix::System::new("websocket-example");

    // Start chat server actor in separate thread
    let server = Arbiter::start(|_| server::ChatServer::default());

    // Create Http server with websocket support
    HttpServer::new(move || {
        // Websocket sessions state
        let state = handler_from_client::WsChatSessionState {
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
            .resource("/ws/", |r| r.route().f(handler_from_client::chat_route))
        // static resources
            .handler("/static/", fs::StaticFiles::new("static/").unwrap())
    }).bind("127.0.0.1:5566")
        .unwrap()
        .start();

    println!("Started http server: 127.0.0.1:5566");
    let _ = sys.run();
}
