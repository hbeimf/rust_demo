use futures::Stream;
use std::str::FromStr;

use std::{io, net};
use tokio_codec::FramedRead;
use tokio_io::io::WriteHalf;
use tokio_io::AsyncRead;
use tokio_tcp::{TcpListener, TcpStream};

use actix::prelude::*;

use glib::codec::{ChatCodec, ChatRequest, ChatResponse};
use table;
use table::table_room::{RoomActor};

// ===================================
use crate::parse_package_from_tcp;

pub struct ChatSession {
    pub uid: u32,
    room: String,
    pub framed: actix::io::FramedWrite<WriteHalf<TcpStream>, ChatCodec>,
}

impl Actor for ChatSession {
    type Context = Context<Self>;

    fn started(&mut self, ctx: &mut Self::Context) {

    }

    fn stopping(&mut self, ctx: &mut Self::Context) -> Running {
        let act = System::current().registry().get::<RoomActor>();
        act.do_send(table::table_room::Disconnect { uid: self.uid });

        Running::Stop
    }
}

impl actix::io::WriteHandler<io::Error> for ChatSession {}

impl StreamHandler<ChatRequest, io::Error> for ChatSession {
    fn handle(&mut self, msg: ChatRequest, ctx: &mut Context<Self>) {
        match msg {
            ChatRequest::Message(package) => {
                debug!("Peer message XXXX: {:?}", package);
                debug!("room: {:?}", self.room);
//                接收来自gwc的包
                parse_package_from_tcp::parse_package(package, self, ctx);   
            }
        }
    }
}

impl Handler<table::msg::TableMessage> for ChatSession {
    type Result = ();

    fn handle(&mut self, msg: table::msg::TableMessage, ctx: &mut Context<Self>) {
        self.framed.write(ChatResponse::Message(msg.0));
    }
}

impl ChatSession {
    pub fn new(
        framed: actix::io::FramedWrite<WriteHalf<TcpStream>, ChatCodec>,
    ) -> ChatSession {
        ChatSession {
            uid: 0,
            room: "Main".to_owned(),
            framed: framed,
        }
    }

}

pub struct TcpServer {

}

impl TcpServer {
    pub fn new(s: &str) {
        let addr = net::SocketAddr::from_str(s).unwrap();

        let listener = TcpListener::bind(&addr).unwrap();

        TcpServer::create(|ctx| {
            ctx.add_message_stream(
                listener.incoming().map_err(|_| ()).map(|s| TcpConnect(s)),
            );
            TcpServer {}
        });
    }
}

impl Actor for TcpServer {
    type Context = Context<Self>;

    // 这个地方上报到gwc
    fn started(&mut self, ctx: &mut Self::Context) {
        println!("start gwc serv!");
        glib::http_client::report_2_gwc();

    }

    fn stopping(&mut self, ctx: &mut Self::Context) -> Running {
        println!("stop gwc serv!");
        Running::Stop
    }
}

#[derive(Message)]
struct TcpConnect(TcpStream);

impl Handler<TcpConnect> for TcpServer {
    type Result = ();

    fn handle(&mut self, msg: TcpConnect, _: &mut Context<Self>) {
        ChatSession::create(|ctx| {
            let (r, w) = msg.0.split();
            ChatSession::add_stream(FramedRead::new(r, ChatCodec), ctx);
            ChatSession::new(actix::io::FramedWrite::new(w, ChatCodec, ctx))

        });
    }
}
