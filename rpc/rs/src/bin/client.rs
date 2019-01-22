extern crate thrift;
extern crate rs;

use thrift::protocol::{TCompactInputProtocol, TCompactOutputProtocol};
use thrift::transport::{TFramedReadTransport, TFramedWriteTransport, TIoChannel, TTcpChannel};

use std::time::{ Instant};

// use rs::{SimpleServiceSyncClient, TSimpleServiceSyncClient};
use rs::{MsgServiceSyncClient, TMsgServiceSyncClient};

fn main() {
    let now = Instant::now();
    match run() {
        Ok(()) => println!("client ran successfully"),
        Err(e) => {
            println!("client failed with error {:?}", e);
            std::process::exit(1);
        }
    }
    println!("{:?}", now.elapsed());
}

fn run() -> thrift::Result<()> {
    // build our client and connect to the host:port
    let mut c = TTcpChannel::new();
    c.open("127.0.0.1:9999")?;
    let (i_chan, o_chan) = c.split()?;

    // build the input/output protocol
    let i_prot = TCompactInputProtocol::new(TFramedReadTransport::new(i_chan));
    let o_prot = TCompactOutputProtocol::new(TFramedWriteTransport::new(o_chan));

    // use the input/output protocol to create a Thrift client
    let mut client = MsgServiceSyncClient::new(i_prot, o_prot);

    // make service calls
    // let msg = rs::Message::new(Some(100), Some("hello".to_owned()));
    let msg = rs::Message::new(100, "hello".to_owned());

    // left msg = rs::Message::default();
    let res = client.hello(msg)?;
    // let res = client.hello("Allen".to_owned())?;
    println!("{:?}", res);

    // done!
    Ok(())
}