use glib;
use session::{ChatSession};
// use actix_web::{ ws};
// use server;
use actix::ActorContext;

use msg_proto;

use codec::{ChatResponse};

// use std::net;
// use std::str::FromStr;

use actix::prelude::*;
// use futures::Stream;
// use tokio_io::codec::FramedRead;
// use tokio_codec::FramedRead;

// use tokio_io::AsyncRead;
// use tokio_tcp::{TcpListener, TcpStream};

// 解包
pub fn parse_package(package: Vec<u8>, client: &mut ChatSession, ctx: &mut actix::Context<ChatSession>)  {

    let unpackage = glib::unpackage(package);

    match unpackage {
        Some(glib::UnPackageResult{len:_len, cmd, pb}) => {
            action(cmd, pb, client, ctx);
        }
        None => {
        	// 如果解包失败，直接关掉连接
            debug!("unpackage error ...");
            ctx.stop();
        }
    }
}

// 业务逻辑部分
fn action(_cmd:u32, pb:Vec<u8>, client: &mut ChatSession, _ctx: &mut actix::Context<ChatSession>) {
	//parse pb logic 
	let test_msg = msg_proto::decode_msg(pb);
    debug!("name: {:?}", test_msg.get_name());
    debug!("nick_name:{:?}", test_msg.get_nick_name());
    debug!("phone: {:?}", test_msg.get_phone());

    // reply 
    let encode:Vec<u8> = msg_proto::encode_msg();
    let cmd:u32 = 123;
    let reply_package = glib::package(cmd, encode);

    // 直接发给客户端
    // let reply_package1 = reply_package.clone();
    debug!("reply_package: {:?}", reply_package);
    client.framed.write(ChatResponse::Message(reply_package));

    // // 给其它在线的客户发个广播
    // ctx.state().addr.do_send(server::ClientMessageBin {
    //     id: client.id,
    //     msg: reply_package,
    //     room: client.room.clone(),
    // })

}
