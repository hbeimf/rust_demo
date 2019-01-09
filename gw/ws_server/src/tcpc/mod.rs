use actix::*;
use futures::Future;
use std::str::FromStr;
use std::time::Duration;
use std::{io, net};

use tokio_codec::FramedRead;
use tokio_io::io::WriteHalf;
use tokio_io::AsyncRead;
use tokio_tcp::TcpStream;

use glib::codec;

use glib;
use crate::gen_server::{WsChatSession};

pub fn start_tcpc(addr_from: actix::Addr<WsChatSession>) {
    // Connect to server
    let addr = net::SocketAddr::from_str("127.0.0.1:8002").unwrap();
    Arbiter::spawn(
        TcpStream::connect(&addr)
            .and_then(|stream| {
                let addr = TcpClient::create(|ctx| {
                    let (r, w) = stream.split();
                    TcpClient::add_stream(
                        FramedRead::new(r, codec::ClientChatCodec),
                        ctx,
                    );
                    TcpClient {
                        framed: actix::io::FramedWrite::new(
                            w,
                            codec::ClientChatCodec,
                            ctx,
                        ),
                        client_addr:addr_from
                    }
                });

                futures::future::ok(())
            })
            .map_err(|e| {
                debug!("不能建立连接: {}", e);
                ()
            }),
    );

}

pub struct TcpClient {
    framed: actix::io::FramedWrite<WriteHalf<TcpStream>, codec::ClientChatCodec>,
    client_addr: actix::Addr<WsChatSession>,
}

#[derive(Message)]
pub struct ConnectTcpcAddrMsg{
    pub addr: actix::Addr<TcpClient>,
}

#[derive(Message)]
pub struct DeconnectTcpcAddrMsg{
    
}

#[derive(Message, Debug)]
pub struct PackageFromClient(pub Vec<u8>);

impl Actor for TcpClient {
    type Context = Context<Self>;

    fn started(&mut self, ctx: &mut Context<Self>) {
    	// debug!("建立了一个tcp连接？？！！");
    	// 当连接建立的时候，将addr 发送给 client_addr
        let tcpc_addr = ctx.address();
        let tcpc_addr_msg = ConnectTcpcAddrMsg{
            addr: tcpc_addr,
        };

        self.client_addr.do_send(tcpc_addr_msg);

        // start heartbeats otherwise server will disconnect after 10 seconds
        self.hb(ctx)
    }

    fn stopped(&mut self, _: &mut Context<Self>) {
        // debug!("tcp连接断开了！！");

        let tcpc_addr_msg = DeconnectTcpcAddrMsg{
        };

        self.client_addr.do_send(tcpc_addr_msg);

        // Stop application on disconnect
        // System::current().stop();
    }
}

// 客户端转发过来的包，
impl Handler<PackageFromClient> for TcpClient {
    type Result = ();

    fn handle(&mut self, package: PackageFromClient, ctx: &mut Context<Self>) {
        // debug!("客户端转发过来的包: {:?}", package);
        // self.wsc_write.binary(package.0)
        self.framed.write(codec::ChatRequest::Message(package.0));
    }
}

impl TcpClient {
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

impl actix::io::WriteHandler<io::Error> for TcpClient {}

/// Server communication
impl StreamHandler<codec::ChatResponse, io::Error> for TcpClient {
    fn handle(&mut self, msg: codec::ChatResponse, _: &mut Context<Self>) {
        match msg {
            codec::ChatResponse::Message(ref msg) => {
                // println!("message: {}", msg);

                debug!("tcpc 收到来自dev端的package: {:?}", msg);
            },
        }
    }
}
