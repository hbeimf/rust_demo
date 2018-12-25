//! `ClientSession` is an actor, it manages peer tcp connection and
//! proxies commands from peer to `RoomActor`.
// extern crate tokio;
// // extern crate futures;
// use futures::Future;

use futures::Stream;
use std::str::FromStr;
// use std::time::{Duration, Instant};
// use std::time::{Instant};

use std::{io, net};
use tokio_codec::FramedRead;
use tokio_io::io::WriteHalf;
use tokio_io::AsyncRead;
use tokio_tcp::{TcpListener, TcpStream};

use actix::prelude::*;

use tcps::codec::{ChatCodec, ChatRequest, ChatResponse};
use hub;
use hub::gen_server::{RoomActor};

// ===================================
use tcps::parse_package_from_tcp;

/// Chat server sends this messages to session
#[derive(Message, Debug)]
pub struct Message(pub Vec<u8>);

/// `ChatSession` actor is responsible for tcp peer communications.
pub struct ChatSession {
    /// unique session id
    id: u32,
    // /// this is address of chat server
    // addr: Addr<RoomActor>,
    // /// Client must send ping at least once per 10 seconds, otherwise we drop
    // /// connection.
    // hb: Instant,
    /// joined room
    room: String,
    /// Framed wrapper
    pub framed: actix::io::FramedWrite<WriteHalf<TcpStream>, ChatCodec>,
}

impl Actor for ChatSession {
    /// For tcp communication we are going to use `FramedContext`.
    /// It is convenient wrapper around `Framed` object from `tokio_io`
    type Context = Context<Self>;

    fn started(&mut self, ctx: &mut Self::Context) {
        // // we'll start heartbeat process on session start.
        // self.hb(ctx);

        // register self in chat server. `AsyncContext::wait` register
        // future within context, but context waits until this future resolves
        // before processing any other events.
        // let addr = ctx.address();
        // self.addr
        //     .send(room::Connect {
        //         uid: 123456u32,
        //         addr: addr.recipient(),
        //     })
        //     .into_actor(self)
        //     .then(|res, act, ctx| {
        //         match res {
        //             Ok(res) => act.id = res,
        //             // something is wrong with chat server
        //             _ => ctx.stop(),
        //         }
        //         actix::fut::ok(())
        //     })
        //     .wait(ctx);

        // call 
        // let addr = ctx.address();
        // let act = System::current().registry().get::<RoomActor>();
        // let connect_msg = hub::gen_server::Connect {
        //         uid: 123456u32,
        //         addr: addr.recipient(),
        //     };

        // let res = act.send(connect_msg);
        // tokio::spawn(
        //     res.map(|res| {
        //         println!("call result: {:?}", res);
        //     }).map_err(|_| ()),
        // );        
    }

    fn stopping(&mut self, ctx: &mut Self::Context) -> Running {
        // notify chat server
        // self.addr.do_send(hub::gen_server::Disconnect { id: self.id });

        let act = System::current().registry().get::<RoomActor>();
        act.do_send(hub::gen_server::Disconnect { id: self.id });

        Running::Stop
    }
}

impl actix::io::WriteHandler<io::Error> for ChatSession {}

/// To use `Framed` we have to define Io type and Codec
impl StreamHandler<ChatRequest, io::Error> for ChatSession {
    /// This is main event loop for client requests
    fn handle(&mut self, msg: ChatRequest, ctx: &mut Context<Self>) {
        match msg {
            // ChatRequest::List => {
            //     // Send ListRooms message to chat server and wait for response
            //     println!("List rooms");
            //     self.addr
            //         .send(server::ListRooms)
            //         .into_actor(self)
            //         .then(|res, act, ctx| {
            //             match res {
            //                 Ok(rooms) => {
            //                     act.framed.write(ChatResponse::Rooms(rooms));
            //                 }
            //                 _ => println!("Something is wrong"),
            //             }
            //             actix::fut::ok(())
            //         })
            //         .wait(ctx)
            //     // .wait(ctx) pauses all events in context,
            //     // so actor wont receive any new messages until it get list of rooms back
            // }
            // ChatRequest::Join(name) => {
            //     println!("Join to room: {}", name);
            //     self.room = name.clone();
            //     self.addr.do_send(server::Join {
            //         id: self.id,
            //         name: name.clone(),
            //     });
            //     self.framed.write(ChatResponse::Joined(name));
            // }
            ChatRequest::Message(package) => {
                // send message to chat server
                // println!("Peer message: {}", message);
                // self.addr.do_send(server::Message {
                //     id: self.id,
                //     msg: message,
                //     room: self.room.clone(),
                // })
                debug!("Peer message XXXX: {:?}", package);
                debug!("room: {:?}", self.room);
                parse_package_from_tcp::parse_package(package, self, ctx);   
            }
            // // we update heartbeat time on ping from peer
            // ChatRequest::Ping => self.hb = Instant::now(),
        }
    }
}

/// Handler for Message, chat server sends this message, we just send string to
/// peer
impl Handler<Message> for ChatSession {
    type Result = ();

    fn handle(&mut self, msg: Message, ctx: &mut Context<Self>) {
        // send message to peer
        self.framed.write(ChatResponse::Message(msg.0));
    }
}

/// Helper methods
impl ChatSession {
    pub fn new(
        // addr: Addr<RoomActor>,
        framed: actix::io::FramedWrite<WriteHalf<TcpStream>, ChatCodec>,
    ) -> ChatSession {
        ChatSession {
            id: 0,
            // addr: addr,
            // hb: Instant::now(),
            room: "Main".to_owned(),
            framed: framed,
        }
    }

    // /// helper method that sends ping to client every second.
    // ///
    // /// also this method check heartbeats from client
    // fn hb(&self, ctx: &mut Context<Self>) {
    //     ctx.run_interval(Duration::new(1, 0), |act, ctx| {
    //         // check client heartbeats
    //         if Instant::now().duration_since(act.hb) > Duration::new(10, 0) {
    //             // heartbeat timed out
    //             println!("Client heartbeat failed, disconnecting!");

    //             // notify chat server
    //             act.addr.do_send(server::Disconnect { id: act.id });

    //             // stop actor
    //             ctx.stop();
    //         }

    //         // act.framed.write(ChatResponse::Ping);
    //         // if we can not send message to sink, sink is closed (disconnected)
    //     });
    // }
}

/// Define tcp server that will accept incoming tcp connection and create
/// chat actors.
pub struct TcpServer {
    // chat: Addr<RoomActor>,
}

impl TcpServer {
    pub fn new(s: &str) {
        // Create server listener
        // let addr = net::SocketAddr::from_str("127.0.0.1:12345").unwrap();
        let addr = net::SocketAddr::from_str(s).unwrap();

        let listener = TcpListener::bind(&addr).unwrap();

        // Our chat server `Server` is an actor, first we need to start it
        // and then add stream on incoming tcp connections to it.
        // TcpListener::incoming() returns stream of the (TcpStream, net::SocketAddr)
        // items So to be able to handle this events `Server` actor has to
        // implement stream handler `StreamHandler<(TcpStream,
        // net::SocketAddr), io::Error>`
        TcpServer::create(|ctx| {
            ctx.add_message_stream(
                listener.incoming().map_err(|_| ()).map(|s| TcpConnect(s)),
            );
            // TcpServer { chat: chat }
            TcpServer {  }

        });
    }
}

/// Make actor from `Server`
impl Actor for TcpServer {
    /// Every actor has to provide execution `Context` in which it can run.
    type Context = Context<Self>;
}

#[derive(Message)]
struct TcpConnect(TcpStream);

/// Handle stream of TcpStream's
impl Handler<TcpConnect> for TcpServer {
    type Result = ();

    fn handle(&mut self, msg: TcpConnect, _: &mut Context<Self>) {
        // For each incoming connection we create `ChatSession` actor
        // with out chat server address.
        // let server = self.chat.clone();
        ChatSession::create(|ctx| {
            let (r, w) = msg.0.split();
            ChatSession::add_stream(FramedRead::new(r, ChatCodec), ctx);
            // ChatSession::new(server, actix::io::FramedWrite::new(w, ChatCodec, ctx))
            ChatSession::new(actix::io::FramedWrite::new(w, ChatCodec, ctx))

        });
    }
}
