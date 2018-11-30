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
mod handler_from_client;
mod parse_package_from_ws;
// mod server_ws;

// /// How often heartbeat pings are sent
// const HEARTBEAT_INTERVAL: Duration = Duration::from_secs(5);
// /// How long before lack of client response causes a timeout
// const CLIENT_TIMEOUT: Duration = Duration::from_secs(10);

// /// This is our websocket route state, this state is shared with all route
// /// instances via `HttpContext::state()`
// struct WsChatSessionState {
//     addr: Addr<server::ChatServer>,
// }

// /// Entry point for our route
// fn chat_route(req: &HttpRequest<WsChatSessionState>) -> Result<HttpResponse, Error> {
//     ws::start(
//         req,
//         WsChatSession {
//             id: 0,
//             hb: Instant::now(),
//             room: "Main".to_owned(),
//             name: None,
//         },
//     )
// }

// struct WsChatSession {
//     /// unique session id
//     id: usize,
//     /// Client must send ping at least once per 10 seconds (CLIENT_TIMEOUT),
//     /// otherwise we drop connection.
//     hb: Instant,
//     /// joined room
//     room: String,
//     /// peer name
//     name: Option<String>,
// }

// impl Actor for WsChatSession {
//     type Context = ws::WebsocketContext<Self, WsChatSessionState>;

//     /// Method is called on actor start.
//     /// We register ws session with ChatServer
//     fn started(&mut self, ctx: &mut Self::Context) {
//         // register self in chat server. `AsyncContext::wait` register
//         // future within context, but context waits until this future resolves
//         // before processing any other events.
//         // HttpContext::state() is instance of WsChatSessionState, state is shared
//         // across all routes within application

//         // we'll start heartbeat process on session start.
//         self.hb(ctx);

//         let addr = ctx.address();
//         ctx.state()
//             .addr
//             .send(server::Connect {
//                 addr: addr.recipient(),
//             })
//             .into_actor(self)
//             .then(|res, act, ctx| {
//                 match res {
//                     Ok(res) => act.id = res,
//                     // something is wrong with chat server
//                     _ => ctx.stop(),
//                 }
//                 fut::ok(())
//             })
//             .wait(ctx);
//     }

//     fn stopping(&mut self, ctx: &mut Self::Context) -> Running {
//         // notify chat server
//         ctx.state().addr.do_send(server::Disconnect { id: self.id });
//         Running::Stop
//     }
// }

// /// Handle messages from chat server, we simply send it to peer websocket
// impl Handler<session::Message> for WsChatSession {
//     type Result = ();

//     fn handle(&mut self, msg: session::Message, ctx: &mut Self::Context) {
//         ctx.text(msg.0);
//     }
// }

// /// WebSocket message handler
// impl StreamHandler<ws::Message, ws::ProtocolError> for WsChatSession {
//     fn handle(&mut self, msg: ws::Message, ctx: &mut Self::Context) {
//         // println!("WEBSOCKET MESSAGE: {:?}", msg);
//         match msg {
//             ws::Message::Ping(msg) => {
//                 self.hb = Instant::now();
//                 ctx.pong(&msg);
//             }
//             ws::Message::Pong(_) => {
//                 self.hb = Instant::now();
//             }
//             ws::Message::Text(text) => {
//                 println!("===============text msg: {:?}", text);
//                 let m = text.trim();
                
//                 let msg = if let Some(ref name) = self.name {
//                     format!("{}: {}", name, m)
//                 } else {
//                     m.to_owned()
//                 };
//                 // send message to chat server
//                 ctx.state().addr.do_send(server::Message {
//                     id: self.id,
//                     msg: msg,
//                     room: self.room.clone(),
//                 })
               
//             }
//             ws::Message::Binary(bin) => {
//                 println!("XXXXXXX============= binary msg============");
//                 ctx.state().addr.do_send(server::Message {
//                         id: self.id,
//                         msg: "binary".to_owned(),
//                         room: self.room.clone(),
//                     })

//             }
//             ws::Message::Close(_) => {
//                 ctx.stop();
//             },
//         }
//     }
// }

// impl WsChatSession {
//     /// helper method that sends ping to client every second.
//     ///
//     /// also this method checks heartbeats from client
//     fn hb(&self, ctx: &mut ws::WebsocketContext<Self, WsChatSessionState>) {
//         ctx.run_interval(HEARTBEAT_INTERVAL, |act, ctx| {
//             // check client heartbeats
//             if Instant::now().duration_since(act.hb) > CLIENT_TIMEOUT {
//                 // heartbeat timed out
//                 println!("Websocket Client heartbeat failed, disconnecting!");

//                 // notify chat server
//                 ctx.state()
//                     .addr
//                     .do_send(server::Disconnect { id: act.id });

//                 // stop actor
//                 ctx.stop();

//                 // don't try to send a ping
//                 return;
//             }

//             ctx.ping("");
//         });
//     }
// }

fn main() {
    // 初始化日志功能
    easy_logging::init(module_path!(), log::Level::Debug).unwrap();
    // easy_logging::init(module_path!(), log::Level::Info).unwrap();

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
            // .resource("/ws/", |r| r.route().f(chat_route))
            .resource("/ws/", |r| r.route().f(handler_from_client::chat_route))
            // static resources
            .handler("/static/", fs::StaticFiles::new("static/").unwrap())
    }).bind("127.0.0.1:5566")
        .unwrap()
        .start();

    debug!("Started http server: 127.0.0.1:5566");
    let _ = sys.run();
}
