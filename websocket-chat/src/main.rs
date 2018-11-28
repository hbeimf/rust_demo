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

use std::time::{Instant, Duration};

use actix::*;
use actix_web::server::HttpServer;
use actix_web::{fs, http, ws, App, Error, HttpRequest, HttpResponse};

mod server;
mod protos;
mod glib;


/// How often heartbeat pings are sent
const HEARTBEAT_INTERVAL: Duration = Duration::from_secs(5);
/// How long before lack of client response causes a timeout
const CLIENT_TIMEOUT: Duration = Duration::from_secs(10);

/// This is our websocket route state, this state is shared with all route
/// instances via `HttpContext::state()`
struct WsChatSessionState {
    addr: Addr<server::ChatServer>,
}

/// Entry point for our route
fn chat_route(req: &HttpRequest<WsChatSessionState>) -> Result<HttpResponse, Error> {
    ws::start(
        req,
        WsChatSession {
            id: 0,
            hb: Instant::now(),
            room: "Main".to_owned(),
            // name: None,
        },
    )
}

struct WsChatSession {
    /// unique session id
    id: usize,
    /// Client must send ping at least once per 10 seconds (CLIENT_TIMEOUT),
    /// otherwise we drop connection.
    hb: Instant,
    /// joined room
    room: String,
    // /// peer name
    // name: Option<String>,
}

impl Actor for WsChatSession {
    type Context = ws::WebsocketContext<Self, WsChatSessionState>;

    /// Method is called on actor start.
    /// We register ws session with ChatServer
    fn started(&mut self, ctx: &mut Self::Context) {
        // we'll start heartbeat process on session start.
        self.hb(ctx);

        // register self in chat server. `AsyncContext::wait` register
        // future within context, but context waits until this future resolves
        // before processing any other events.
        // HttpContext::state() is instance of WsChatSessionState, state is shared
        // across all routes within application

        // 向server注册客户端 ，此处逻辑可以移除
        // 等到收到某个登录消息后，将uid，name一起放到Connect消息里发送
        // server::Connect 结构体内加上uid, name 
        let addr = ctx.address();
        ctx.state()
            .addr
            .send(server::Connect {
                addr: addr.recipient(),
            })
            .into_actor(self)
            .then(|res, act, ctx| {
                match res {
                    Ok(res) => act.id = res,
                    // something is wrong with chat server
                    _ => ctx.stop(),
                }
                fut::ok(())
            })
            .wait(ctx);
    }

    fn stopping(&mut self, ctx: &mut Self::Context) -> Running {
        // notify chat server
        // session actor 结束了，通知 server actor
        ctx.state().addr.do_send(server::Disconnect { id: self.id });
        Running::Stop
    }
}

/// Handle messages from chat server, we simply send it to peer websocket
// 发送数据给客户端 ， 
impl Handler<server::Message> for WsChatSession {
    type Result = ();

    // server 处理逻辑后将回复发送到此处
    fn handle(&mut self, msg: server::Message, ctx: &mut Self::Context) {
        println!("transport: {:?}", msg);
        let server::Message(bin_reply) = msg;
        // ctx.text(msg.0);
        // ctx.text(str_reply);
        // if bin_reply.len() == 0 {
        //     // 回复text 串
        //     ctx.text(str_reply);
        // } else {
            // 回复二进制数据
            ctx.binary(bin_reply);
        // }   
        
        // ws::Message::Binary::from(msg.1)
    }
}


/// WebSocket message handler
// 接收来自客户端的数据， 只接收二进制数据， text 类型的数据收到后，连接将强制关闭，
impl StreamHandler<ws::Message, ws::ProtocolError> for WsChatSession {

    // 收到消息后发给server actor
    fn handle(&mut self, msg: ws::Message, ctx: &mut Self::Context) {
        // println!("WEBSOCKET MESSAGE: {:?}", msg);
        match msg {
            ws::Message::Ping(msg) => {
                self.hb = Instant::now();
                ctx.pong(&msg);
            }
            ws::Message::Pong(_) => {
                self.hb = Instant::now();
            }
            ws::Message::Text(text) => {
                println!("WEBSOCKET text MESSAGE: {:?}", text);
                // 不关注字符串消息，直接关闭连接 
                ctx.stop()

            }
            ws::Message::Binary(bin) => {
                // 只接收二进制数据包，按照协议解析完成逻辑即可，
                glib::test();
                // println!("Unexpected binary");
                println!("binary message {:?}", bin);
                // glib::decode_msg(bin.as_ref().to_vec());
                let package = bin.as_ref().to_vec();
                // println!("packageX {:?}", package);
                // let unpackage = glib::unpackage(package);
                // glib::test_unpackage(package);
               
                println!("state, id: {}", self.id);
                println!("state, room: {}", self.room);
                // println!("state, name: {}", self.name);


                ctx.state().addr.do_send(server::ClientMessageBin {
                    id: self.id,
                    msg: package,
                    room: self.room.clone(),
                })
            }
            ws::Message::Close(_) => {
                ctx.stop();
            },
        }
    }
}


// 心跳 ping 
impl WsChatSession {
    /// helper method that sends ping to client every second.
    ///
    /// also this method checks heartbeats from client
    fn hb(&self, ctx: &mut ws::WebsocketContext<Self, WsChatSessionState>) {
        ctx.run_interval(HEARTBEAT_INTERVAL, |act, ctx| {
            // check client heartbeats
            if Instant::now().duration_since(act.hb) > CLIENT_TIMEOUT {
                // heartbeat timed out
                println!("Websocket Client heartbeat failed, disconnecting!");

                // notify chat server
                ctx.state()
                    .addr
                    .do_send(server::Disconnect { id: act.id });

                // stop actor
                ctx.stop();

                // don't try to send a ping
                return;
            }

            ctx.ping("");
        });
    }
}

fn main() {
    // glib::test();
    let _ = env_logger::init();
    let sys = actix::System::new("websocket-example");

    // Start chat server actor in separate thread
    let server = Arbiter::start(|_| server::ChatServer::default());

    // Create Http server with websocket support
    HttpServer::new(move || {
        // Websocket sessions state
        let state = WsChatSessionState {
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
            .resource("/ws/", |r| r.route().f(chat_route))
        // static resources
            .handler("/static/", fs::StaticFiles::new("static/").unwrap())
    }).bind("127.0.0.1:5566")
        .unwrap()
        .start();

    println!("Started http server: 127.0.0.1:5566");
    let _ = sys.run();
}
