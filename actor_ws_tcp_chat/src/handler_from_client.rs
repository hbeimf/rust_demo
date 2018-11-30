use std::time::{Instant, Duration};

use actix::*;
// use actix_web::server::HttpServer;
use actix_web::{ ws, Error, HttpRequest, HttpResponse};

use server;
// use glib;
use parse_package_from_ws;

/// How often heartbeat pings are sent
const HEARTBEAT_INTERVAL: Duration = Duration::from_secs(5);
/// How long before lack of client response causes a timeout
const CLIENT_TIMEOUT: Duration = Duration::from_secs(10);

/// This is our websocket route state, this state is shared with all route
/// instances via `HttpContext::state()`
pub struct WsChatSessionState {
    pub addr: Addr<server::ChatServer>,
}

/// Entry point for our route
pub fn chat_route(req: &HttpRequest<WsChatSessionState>) -> Result<HttpResponse, Error> {
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

pub struct WsChatSession {
    /// unique session id
    pub id: usize,
    /// Client must send ping at least once per 10 seconds (CLIENT_TIMEOUT),
    /// otherwise we drop connection.
    pub hb: Instant,
    /// joined room
    pub room: String,
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
        // let addr = ctx.address();
        // ctx.state()
        //     .addr
        //     .send(server::Connect {
        //         addr: addr.recipient(),
        //     })
        //     .into_actor(self)
        //     .then(|res, act, ctx| {
        //         match res {
        //             Ok(res) => act.id = res,
        //             // something is wrong with chat server
        //             _ => ctx.stop(),
        //         }
        //         fut::ok(())
        //     })
        //     .wait(ctx);
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
        // // println!("transport: {:?}", msg);
        // let server::Message(bin_reply) = msg;  
        // // 回复二进制数据
        // ctx.binary(bin_reply);
    }
}


/// WebSocket message handler
// 接收来自客户端的数据， 只接收二进制数据， text 类型的数据收到后，连接将强制关闭，
impl StreamHandler<ws::Message, ws::ProtocolError> for WsChatSession {

    // 收到消息后发给server actor
    fn handle(&mut self, msg: ws::Message, ctx: &mut Self::Context) {
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
                println!("binary message {:?}", bin);
                let package = bin.as_ref().to_vec();
                parse_package_from_ws::parse_package(package, self, ctx);
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

