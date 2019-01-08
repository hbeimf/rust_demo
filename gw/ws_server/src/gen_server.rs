use glib;
use crate::action;
use actix::ActorContext;

use std::time::{Instant, Duration};

use actix::*;
use actix_web::{ ws, Error, HttpRequest, HttpResponse};

use table;
use table::table_room::{RoomActor, Disconnect};
use crate::wsc;
use crate::tcpc;

const HEARTBEAT_INTERVAL: Duration = Duration::from_secs(5);
const CLIENT_TIMEOUT: Duration = Duration::from_secs(10);

pub struct WsChatSessionState {

}

pub fn chat_route(req: &HttpRequest<WsChatSessionState>) -> Result<HttpResponse, Error> {
    ws::start(
        req,
        WsChatSession {
            uid: 0,
            hb: Instant::now(),
            room: "Main".to_owned(),
            // name: None,
            addr_wsc:None,
            addr_tcpc:None,
        },
    )
}

pub struct WsChatSession {
    pub uid: u32,
    pub hb: Instant,
    pub room: String,
    // 启动一个与后端连接的 wsc，这里放这个连接actor的 addr
    pub addr_wsc: Option<actix::Addr<wsc::gen_server::ChatClient>>,
    // 启动一个与后端连接的 tcpc，这里放这个连接actor的 addr
    pub addr_tcpc: Option<actix::Addr<tcpc::ChatClient>>,
       
}

impl Actor for WsChatSession {
    type Context = ws::WebsocketContext<Self, WsChatSessionState>;

    fn started(&mut self, ctx: &mut Self::Context) {
        // we'll start heartbeat process on session start.
        self.hb(ctx);
    }

    fn stopping(&mut self, ctx: &mut Self::Context) -> Running {
        let act = System::current().registry().get::<RoomActor>();
        act.do_send(Disconnect { uid: self.uid });
        Running::Stop
    }
}

// 发送数据给客户端 ， 
impl Handler<table::msg::TableMessage> for WsChatSession {
    type Result = ();

    // server 处理逻辑后将回复发送到此处
    fn handle(&mut self, msg: table::msg::TableMessage, ctx: &mut Self::Context) {
        debug!("wss actor 收到 session::Message 消息: {:?}", msg);
        // 匹配提取二进制
        let table::msg::TableMessage(msg_bin) = msg;  
        // 回复二进制数据
        ctx.binary(msg_bin);
    }
}

impl Handler<wsc::gen_server::ConnectWscAddrMsg> for WsChatSession {
    type Result = ();

    // server 处理逻辑后将回复发送到此处
    fn handle(&mut self, wsc_addr_msg: wsc::gen_server::ConnectWscAddrMsg, ctx: &mut Self::Context) {
        // debug!("收到新建立连接的addr");
        self.addr_wsc = Some(wsc_addr_msg.addr);
    }
}

impl Handler<wsc::gen_server::DeconnectWscAddrMsg> for WsChatSession {
    type Result = ();

    // server 处理逻辑后将回复发送到此处
    fn handle(&mut self, wsc_addr_msg: wsc::gen_server::DeconnectWscAddrMsg, ctx: &mut Self::Context) {
        // debug!("wsc连接断开了！");
        self.addr_wsc = None;
    }
}


impl Handler<tcpc::ConnectTcpcAddrMsg> for WsChatSession {
    type Result = ();

    // server 处理逻辑后将回复发送到此处
    fn handle(&mut self, tcpc_addr_msg: tcpc::ConnectTcpcAddrMsg, ctx: &mut Self::Context) {
        // debug!("tcpc连接建立成功！！");
        self.addr_tcpc = Some(tcpc_addr_msg.addr);
    }
}


impl Handler<tcpc::DeconnectTcpcAddrMsg> for WsChatSession {
    type Result = ();

    // server 处理逻辑后将回复发送到此处
    fn handle(&mut self, tcpc_addr_msg: tcpc::DeconnectTcpcAddrMsg, ctx: &mut Self::Context) {
        // debug!("tcpc连接断开了！");
        self.addr_tcpc = None;
    }
}

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
                // println!("WEBSOCKET text MESSAGE: {:?}", text);
                // 不关注字符串消息，直接关闭连接 
                ctx.stop()

            }
            ws::Message::Binary(bin) => {
                // let _addr = ctx.address();
                // test_addr(ctx);
                // 只接收二进制数据包，按照协议解析完成逻辑即可，
                // debug!("binary message {:?}", bin);
                let package = bin.as_ref().to_vec();
                parse_package(package, self, ctx);
            }
            ws::Message::Close(_) => {
                ctx.stop();
            },
        }
    }
}


// 解包
pub fn parse_package(package: Vec<u8>, client: &mut WsChatSession, ctx: &mut ws::WebsocketContext<WsChatSession, WsChatSessionState>)  {
    // let _addr = ctx.address();
    let unpackage = glib::unpackage(package.clone());

    match unpackage {
        Some(glib::UnPackageResult{len:_len, cmd, pb}) => {
            match cmd {
                10000 => {
                    action::action_10000(cmd, pb, package, client, ctx);
                }
                _ => {
                    action::action(cmd, pb, package, client, ctx);   
                }
            }
            // action(cmd, pb, package, client, ctx);
        }
        None => {
            // 如果解包失败，直接关掉连接
            debug!("unpackage error ...");
            ctx.stop();
        }
    }
}

// 心跳 ping 
impl WsChatSession {
    fn hb(&self, ctx: &mut ws::WebsocketContext<Self, WsChatSessionState>) {
        ctx.run_interval(HEARTBEAT_INTERVAL, |act, ctx| {
            // check client heartbeats
            if Instant::now().duration_since(act.hb) > CLIENT_TIMEOUT {
                let actor_room = System::current().registry().get::<RoomActor>();
                actor_room.do_send(table::table_room::Disconnect { uid: act.uid });

                // stop actor
                ctx.stop();
                return;
            }

            ctx.ping("");
        });
    }
}

