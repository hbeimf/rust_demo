extern crate thrift;
extern crate rs;

use thrift::protocol::{TCompactInputProtocolFactory, TCompactOutputProtocolFactory};
use thrift::transport::{TFramedReadTransportFactory, TFramedWriteTransportFactory};
use thrift::server::TServer;

use rs::{MsgServiceSyncHandler, MsgServiceSyncProcessor, Message};

fn main() {
    match run() {
        Ok(()) => println!("server ran successfully"),
        Err(e) => {
            println!("server failed with error {:?}", e);
            std::process::exit(1);
        }
    }
}

fn run() -> thrift::Result<()> {
    // set listen address
    let listen_address = "127.0.0.1:9999";

    // create input protocol/transport factory
    let i_tran_fact = TFramedReadTransportFactory::new();
    let i_prot_fact = TCompactInputProtocolFactory::new();

    // create output  protocol/transport factory
    let o_tran_fact = TFramedWriteTransportFactory::new();
    let o_prot_fact = TCompactOutputProtocolFactory::new();

    // create the server and start listening
    let processor = MsgServiceSyncProcessor::new(MsgServiceHandlerImpl { });
    let mut server = TServer::new(
        i_tran_fact,
        i_prot_fact,
        o_tran_fact,
        o_prot_fact,
        processor,
        10,
    );

    println!("binding to {}", listen_address);
    server.listen(&listen_address)
}

// server implementation
#[derive(Default)]
struct MsgServiceHandlerImpl;
impl MsgServiceSyncHandler for MsgServiceHandlerImpl {
    fn handle_hello(&self, msg: Message) -> thrift::Result<Message> {
        println!("{:?}", msg);
        //  let reply_msg = rs::Message::new(Some(101), Some("hello world".to_owned()));
        // Ok(reply_msg)
        Ok(msg)
    }
}