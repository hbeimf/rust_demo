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
use crate::msg::*;
use crate::broker_sup::{BrokerSupActor};

use crate::parse_package;

pub fn start() {
    // Connect to server
    let addr = net::SocketAddr::from_str("127.0.0.1:12345").unwrap();
    Arbiter::spawn(
        TcpStream::connect(&addr)
            .and_then(|stream| {
                let addr = BrokerWorkActor::create(|ctx| {
                    let (r, w) = stream.split();
                    BrokerWorkActor::add_stream(
                        FramedRead::new(r, codec::ClientChatCodec),
                        ctx,
                    );
                    BrokerWorkActor {
                        framed: actix::io::FramedWrite::new(
                            w,
                            codec::ClientChatCodec,
                            ctx,
                        ),
                    }
                });

                debug!("建立了一个tcp连接！！");

                futures::future::ok(())
            })
            .map_err(|e| {
                debug!("不能建立连接: {}", e);
                ()
            }),
    );

}

pub struct BrokerWorkActor {
    framed: actix::io::FramedWrite<WriteHalf<TcpStream>, codec::ClientChatCodec>,
    // p_addr: actix::Addr<WsChatSession>,
}

impl Actor for BrokerWorkActor {
    type Context = Context<Self>;

    // 当连接建立时，向sup注册自己的地址，所有与这个actor 交互的消息都由 sup发过来，
    fn started(&mut self, ctx: &mut Context<Self>) {
    	debug!("建立了一个tcp连接？？！！");
    	// 当连接建立的时候，将addr 发送给 p_addr
        let self_addr = ctx.address().recipient();
        let reg_msg = RegisterBrokerWork{
            id: 1u32,
            addr: self_addr,
        };

        let broker_sup_addr = System::current().registry().get::<BrokerSupActor>();
        broker_sup_addr.do_send(reg_msg);

        // start heartbeats otherwise server will disconnect after 10 seconds
        self.hb(ctx)
    }

    fn stopped(&mut self, _: &mut Context<Self>) {
        debug!("tcp连接断开了！！");

        // let tcpc_addr_msg = DeconnectTcpcAddrMsg{
        // };

        // self.p_addr.do_send(tcpc_addr_msg);

        // Stop application on disconnect
        // System::current().stop();
    }
}

// 客户端转发过来的包，
impl Handler<PackageFromClient> for BrokerWorkActor {
    type Result = ();

    fn handle(&mut self, package: PackageFromClient, ctx: &mut Context<Self>) {
        // debug!("客户端转发过来的包: {:?}", package);
        self.framed.write(codec::ChatRequest::Message(package.0));
    }
}

impl BrokerWorkActor {
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

impl actix::io::WriteHandler<io::Error> for BrokerWorkActor {}

/// Server communication
impl StreamHandler<codec::ChatResponse, io::Error> for BrokerWorkActor {
    fn handle(&mut self, package: codec::ChatResponse, ctx: &mut Context<Self>) {
        match package {
            codec::ChatResponse::Message(package) => {
                println!("收到来自rpmd端的package: {:?}", package);
                debug!("收到来自rpmd端的package: {:?}", package);

                parse_package::parse_package(package, self, ctx);
            },
        }
    }
}
