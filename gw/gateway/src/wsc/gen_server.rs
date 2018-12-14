// Option<actix::Addr<ChatClient>>

//! Simple websocket client.

#![allow(unused_variables)]
extern crate actix;
extern crate actix_web;
// extern crate env_logger;
extern crate futures;

// extern crate gateway;
use wss::gen_server::{WsChatSession};

use std::time::Duration;
// use std::{io, thread};

use actix::*;
use actix_web::ws::{Client, ClientWriter, Message, ProtocolError};
use futures::Future;

// pub fn test() {
//    	start_wsc();
// }


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
                let _addr = ChatClient::create(|ctx| {
                    ChatClient::add_stream(reader, ctx);
                    ChatClient{wsc_write:writer, client_addr:addr}
                });

                // // start console loop
                // thread::spawn(move || loop {
                //     let mut cmd = String::new();
                //     if io::stdin().read_line(&mut cmd).is_err() {
                //         println!("error");
                //         return;
                //     }
                //     addr.do_send(ClientCommand(cmd));
                // });

                ()
            }),
    )
}



pub struct ChatClient{
    wsc_write: ClientWriter, 
    client_addr: actix::Addr<WsChatSession>,
}

#[derive(Message)]
struct ClientCommand(String);

#[derive(Message)]
pub struct ConnectWscAddrMsg{
    pub addr: actix::Addr<ChatClient>,
}

#[derive(Message)]
pub struct DeconnectWscAddrMsg{}


#[derive(Message, Debug)]
pub struct PackageFromClient(pub Vec<u8>);

impl Actor for ChatClient {
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

impl ChatClient {
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
impl Handler<ClientCommand> for ChatClient {
    type Result = ();

    fn handle(&mut self, msg: ClientCommand, ctx: &mut Context<Self>) {
        self.wsc_write.text(msg.0)
    }
}

// 客户端转发过来的包，
impl Handler<PackageFromClient> for ChatClient {
    type Result = ();

    fn handle(&mut self, package: PackageFromClient, ctx: &mut Context<Self>) {
        debug!("客户端转发过来的包: {:?}", package);
        self.wsc_write.binary(package.0)
    }
}





/// Handle server websocket messages
impl StreamHandler<Message, ProtocolError> for ChatClient {
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

