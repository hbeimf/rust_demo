// #[macro_use]
// extern crate actix;
// extern crate byteorder;
// extern crate bytes;
// extern crate futures;
// extern crate serde;
// extern crate serde_json;
// extern crate tokio_codec;
// extern crate tokio_io;
// extern crate tokio_tcp;
// #[macro_use]
// extern crate serde_derive;


// use byteorder;
// use bytes;
// use futures;
// use serde;
// use serde_json;
// use tokio_codec;
// use tokio_io;
// use tokio_tcp;

use actix::*;
use actix::prelude::*;
use futures::Future;
use std::str::FromStr;
use std::time::Duration;
// use std::{io, net, process, thread};
use std::{io, net};

use tokio_codec::FramedRead;
use tokio_io::io::WriteHalf;
use tokio_io::AsyncRead;
use tokio_tcp::TcpStream;

use codec;

use glib;
use handler_from_client_ws::{WsChatSession};

pub fn start_tcpc(addr_from: actix::Addr<WsChatSession>) {
    // let sys = actix::System::new("chat-client");

    // Connect to server
    let addr = net::SocketAddr::from_str("127.0.0.1:8002").unwrap();
    Arbiter::spawn(
        TcpStream::connect(&addr)
            .and_then(|stream| {
                let addr = ChatClient::create(|ctx| {
                    let (r, w) = stream.split();
                    ChatClient::add_stream(
                        FramedRead::new(r, codec::ClientChatCodec),
                        ctx,
                    );
                    ChatClient {
                        framed: actix::io::FramedWrite::new(
                            w,
                            codec::ClientChatCodec,
                            ctx,
                        ),
                        client_addr:addr_from
                    }
                });

                // start console loop
                // thread::spawn(move || loop {
                //     let mut cmd = String::new();
                //     if io::stdin().read_line(&mut cmd).is_err() {
                //         println!("error");
                //         return;
                //     }

                //     // addr.do_send(ClientCommand(cmd));
                //     ()
                // });

                futures::future::ok(())
            })
            .map_err(|e| {
                debug!("不能建立连接: {}", e);
                ()
                // process::exit(1)
            }),
    );

    // println!("Running chat client");
    // sys.run();
}

pub struct ChatClient {
    framed: actix::io::FramedWrite<WriteHalf<TcpStream>, codec::ClientChatCodec>,
    client_addr: actix::Addr<WsChatSession>,
}

// #[derive(Message)]
// struct ClientCommand(String);

#[derive(Message)]
pub struct TcpcAddrMsg{
    pub addr: actix::Addr<ChatClient>,
}

#[derive(Message, Debug)]
pub struct PackageFromClient(pub Vec<u8>);

impl Actor for ChatClient {
    type Context = Context<Self>;

    fn started(&mut self, ctx: &mut Context<Self>) {
    	debug!("建立了一个tcp连接？？！！");
    	// 当连接建立的时候，将addr 发送给 client_addr
        let tcpc_addr = ctx.address();
        let tcpc_addr_msg = TcpcAddrMsg{
            addr: tcpc_addr,
        };

        self.client_addr.do_send(tcpc_addr_msg);

        // start heartbeats otherwise server will disconnect after 10 seconds
        self.hb(ctx)
    }

    fn stopped(&mut self, _: &mut Context<Self>) {
        println!("tcp连接断开了！！");

        // Stop application on disconnect
        // System::current().stop();
    }
}

// 客户端转发过来的包，
impl Handler<PackageFromClient> for ChatClient {
    type Result = ();

    fn handle(&mut self, package: PackageFromClient, ctx: &mut Context<Self>) {
        debug!("客户端转发过来的包: {:?}", package);
        // self.wsc_write.binary(package.0)
        self.framed.write(codec::ChatRequest::Message(package.0));
    }
}

impl ChatClient {
    fn hb(&self, ctx: &mut Context<Self>) {
        ctx.run_later(Duration::new(1, 0), |act, ctx| {
            // act.framed.write(codec::ChatRequest::Ping);
            let ping:Vec<u8> = vec![];
            let msg_ping = glib::package(100u32, ping);
            act.framed.write(codec::ChatRequest::Message(msg_ping));
            act.hb(ctx);

            // client should also check for a timeout here, similar to the
            // server code
        });
    }
}

impl actix::io::WriteHandler<io::Error> for ChatClient {}

// /// Handle stdin commands
// impl Handler<ClientCommand> for ChatClient {
//     type Result = ();

//     fn handle(&mut self, msg: ClientCommand, _: &mut Context<Self>) {
//         let m = msg.0.trim();
//         if m.is_empty() {
//             return;
//         }

//         // we check for /sss type of messages
//         if m.starts_with('/') {
//             let v: Vec<&str> = m.splitn(2, ' ').collect();
//             match v[0] {
//                 "/list" => {
//                     self.framed.write(codec::ChatRequest::List);
//                 }
//                 "/join" => {
//                     if v.len() == 2 {
//                         self.framed.write(codec::ChatRequest::Join(v[1].to_owned()));
//                     } else {
//                         println!("!!! room name is required");
//                     }
//                 }
//                 _ => println!("!!! unknown command"),
//             }
//         } else {
//             self.framed.write(codec::ChatRequest::Message(m.to_owned()));
//         }
//     }
// }

/// Server communication

impl StreamHandler<codec::ChatResponse, io::Error> for ChatClient {
    fn handle(&mut self, msg: codec::ChatResponse, _: &mut Context<Self>) {
        match msg {
            codec::ChatResponse::Message(ref msg) => {
                // println!("message: {}", msg);
            },
            // codec::ChatResponse::Joined(ref msg) => {
            //     println!("!!! joined: {}", msg);
            // }
            // codec::ChatResponse::Rooms(rooms) => {
            //     println!("\n!!! Available rooms:");
            //     for room in rooms {
            //         println!("{}", room);
            //     }
            //     println!("");
            // }
            // _ => (),
        }
    }
}
