#![allow(unused_variables)]
extern crate actix;
extern crate actix_web;
extern crate futures;
use crate::gen_server::{WsChatSession};
use std::time::Duration;
use actix::*;
use actix_web::ws::{Client, ClientWriter, Message, ProtocolError};
use futures::Future;


// 建立一个wscl连接后必须给addr发送一个消息，通知连接已建立成功
pub fn start_wsc(addr: actix::Addr<WsChatSession>) {
	Arbiter::spawn(
        Client::new("ws://localhost:7766/websocket")
            .connect()
            .map_err(|e| {
                debug!("wsc 连接出错了=====================: {}", e);
                ()
            })
            .map(|(reader, writer)| {
                let _addr = WsClient::create(|ctx| {
                    WsClient::add_stream(reader, ctx);
                    WsClient{wsc_write:writer, client_addr:addr}
                });

                ()
            }),
    )
}



pub struct WsClient{
    wsc_write: ClientWriter, 
    client_addr: actix::Addr<WsChatSession>,
}

#[derive(Message)]
struct ClientCommand(String);

#[derive(Message)]
pub struct ConnectWscAddrMsg{
    pub addr: actix::Addr<WsClient>,
}

#[derive(Message)]
pub struct DeconnectWscAddrMsg{}


#[derive(Message, Debug)]
pub struct PackageFromClient(pub Vec<u8>);

impl Actor for WsClient {
    type Context = Context<Self>;

    fn started(&mut self, ctx: &mut Context<Self>) {
    	debug!("与节点建立了一个websocket连接");
        // 当连接建立的时候，将addr 发送给 client_addr
        let wsc_addr = ctx.address();
        let wsc_addr_msg = ConnectWscAddrMsg{
            addr: wsc_addr,
        };

        self.client_addr.do_send(wsc_addr_msg);

        // start heartbeats otherwise server will disconnect after 10 seconds
        self.hb(ctx)
    }

    fn stopped(&mut self, _: &mut Context<Self>) {
        debug!("websocket连接完蛋了");
        let deconnect_wsc_addr_msg = DeconnectWscAddrMsg{};
        self.client_addr.do_send(deconnect_wsc_addr_msg);

        // Stop application on disconnect
        // 如运行下面这句将导制整个进程退出
        // System::current().stop();
    }
}

impl WsClient {
    fn hb(&self, ctx: &mut Context<Self>) {
        ctx.run_later(Duration::new(1, 0), |act, ctx| {
            act.wsc_write.ping("");
            act.hb(ctx);

            // client should also check for a timeout here, similar to the
            // server code
        });
    }
}

/// Handle stdin commands
impl Handler<ClientCommand> for WsClient {
    type Result = ();

    fn handle(&mut self, msg: ClientCommand, ctx: &mut Context<Self>) {
        self.wsc_write.text(msg.0)
    }
}

// 客户端转发过来的包，
impl Handler<PackageFromClient> for WsClient {
    type Result = ();

    fn handle(&mut self, package: PackageFromClient, ctx: &mut Context<Self>) {
        debug!("客户端转发过来的包: {:?}", package);
        self.wsc_write.binary(package.0)
    }
}





/// Handle server websocket messages
impl StreamHandler<Message, ProtocolError> for WsClient {
    fn handle(&mut self, msg: Message, ctx: &mut Context<Self>) {
        // 这里接收来自连接对端发来的包
        match msg {
            Message::Text(txt) => println!("Server: {:?}", txt),
            _ => (),
        }
    }

    fn started(&mut self, ctx: &mut Context<Self>) {
        debug!("Connected");
    }

    fn finished(&mut self, ctx: &mut Context<Self>) {
        debug!("连接断开了,  Server disconnected");
        // 连接断开的时候，actor 必须也跟着结束 
        ctx.stop()
    }
}

