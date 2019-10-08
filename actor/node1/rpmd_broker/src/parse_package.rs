extern crate tokio;
//use futures::Future;
//use table;
//use table::table_room::{RoomActor};

use glib;
use crate::broker_work::{BrokerWorkActor};
use actix::ActorContext;

//use glib::pb::msg_proto;

//use glib::codec::{ChatResponse};

//use actix::prelude::*;

// use tcp_client;
use crate::cmd;

// 解包
pub fn parse_package(package: Vec<u8>, client: &mut BrokerWorkActor, ctx: &mut actix::Context<BrokerWorkActor>)  {

    let unpackage = glib::unpackage(package);

    match unpackage {
        Some(glib::UnPackageResult{len:_len, cmd, pb}) => {
            // action(cmd, pb, client, ctx);
            match cmd {
                cmd::CMD_HB_101 => {
                    // 收到心跳包回复
                    action_heart_beat_101(cmd, pb, client, ctx);
                }
                _ => {
                    action(cmd, pb, client, ctx);
                }
            }
        }
        None => {
            // 如果解包失败，直接关掉连接
            println!("unpackage error ...");
            ctx.stop();
        }
    }
}



// 收到心跳 包
fn action_heart_beat_101(_cmd:u32, pb:Vec<u8>, client: &mut BrokerWorkActor, _ctx: &mut actix::Context<BrokerWorkActor>) {
    println!("receive hb reply");

}


// 业务逻辑部分
fn action(cmd:u32, pb:Vec<u8>, client: &mut BrokerWorkActor, _ctx: &mut actix::Context<BrokerWorkActor>) {
//    // tcp_client::start_tcp_client();
//
//
//    //parse pb logic
//    let test_msg = msg_proto::decode_msg(pb);
//    println!("name: {:?}", test_msg.get_name());
//    println!("nick_name:{:?}", test_msg.get_nick_name());
//    println!("phone: {:?}", test_msg.get_phone());
//
//    // reply
//    let encode:Vec<u8> = msg_proto::encode_msg();
//    let cmd:u32 = 123;
//    let reply_package = glib::package(cmd, encode);
//
//    // 直接发给客户端
//    // let reply_package1 = reply_package.clone();
//    println!("reply_package: {:?}", reply_package);
//    client.framed.write(ChatResponse::Message(reply_package));
//
//    // // 给其它在线的客户发个广播
//    // ctx.state().addr.do_send(server::ClientMessageBin {
//    //     id: client.id,
//    //     msg: reply_package,
//    //     room: client.room.clone(),
//    // })

    println!("cmd: {:?}", cmd);
}
