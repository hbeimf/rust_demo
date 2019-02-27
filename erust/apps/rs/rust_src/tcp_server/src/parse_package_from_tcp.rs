extern crate tokio;
use futures::Future;
use table;
use table::table_room::{RoomActor};

use glib;
use crate::gen_server::{ChatSession};
use actix::ActorContext;

use glib::pb::msg_proto;

use glib::codec::{ChatResponse};

use actix::prelude::*;

// use tcp_client;
use crate::cmd;

// 解包
pub fn parse_package(package: Vec<u8>, client: &mut ChatSession, ctx: &mut actix::Context<ChatSession>)  {

    let unpackage = glib::unpackage(package);

    match unpackage {
        Some(glib::UnPackageResult{len:_len, cmd, pb}) => {
            // action(cmd, pb, client, ctx);
            match cmd {
                cmd::CMD_LOGIN_10000 => {
                    action_10000(cmd, pb, client, ctx);
                }
                10008 => {
                    action_call_10008(cmd, pb, client, ctx);
                }
                10010 => {
                    action_cast_10010(cmd, pb, client, ctx);
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

// 业务逻辑部分
fn action_10000(_cmd:u32, pb:Vec<u8>
    , client: &mut ChatSession, ctx: &mut actix::Context<ChatSession>) {
    // tcp_client::start_tcp_client();
    

    let login_msg = msg_proto::decode_login(pb);
    println!("uid: {:?}", login_msg.get_uid());
    let uid = login_msg.get_uid();
    client.uid = uid as u32; // 登录成功后初始化uid

    // call 
    let addr_client = ctx.address();
    let act = System::current().registry().get::<RoomActor>();
    let connect_msg = table::table_room::Connect {
            uid: uid as u32,
            addr: addr_client.recipient(),
        };
    let res = act.send(connect_msg);
    tokio::spawn(
        res.map(|res| {
            println!("call result: {:?}", res);
        }).map_err(|_| ()),
    );     


}

// 业务逻辑部分
fn action_call_10008(_cmd:u32, pb:Vec<u8>
    , client: &mut ChatSession, _ctx: &mut actix::Context<ChatSession>) {
    // tcp_client::start_tcp_client();

    //parse pb logic 
    let rpc_msg = msg_proto::decode_rpc(pb);
    println!("key: {:?}", rpc_msg.get_key());
    println!("payload:{:?}", rpc_msg.get_payload());

    // reply 
    let encode:Vec<u8> = msg_proto::encode_msg();
    let cmd:u32 = 10008;
    let rpc_reply = msg_proto::encode_rpc(rpc_msg.get_key().to_string(), encode);
    let reply_package = glib::package(cmd, rpc_reply);

    // 直接发给客户端
    println!("reply_package: {:?}", reply_package);
    client.framed.write(ChatResponse::Message(reply_package));

    // // 给其它在线的客户发个广播
    // ctx.state().addr.do_send(server::ClientMessageBin {
    //     id: client.id,
    //     msg: reply_package,
    //     room: client.room.clone(),
    // })

}

// 业务逻辑部分
fn action_cast_10010(_cmd:u32, pb:Vec<u8>, client: &mut ChatSession, _ctx: &mut actix::Context<ChatSession>) {

    // reply
    let encode:Vec<u8> = msg_proto::encode_msg();
    let cmd:u32 = 10010;
    let reply_package = glib::package(cmd, encode);

    // 直接发给客户端
    client.framed.write(ChatResponse::Message(reply_package));
}

// 业务逻辑部分
fn action(_cmd:u32, pb:Vec<u8>
    , client: &mut ChatSession, _ctx: &mut actix::Context<ChatSession>) {
    // tcp_client::start_tcp_client();
    

	//parse pb logic 
	let test_msg = msg_proto::decode_msg(pb);
    println!("name: {:?}", test_msg.get_name());
    println!("nick_name:{:?}", test_msg.get_nick_name());
    println!("phone: {:?}", test_msg.get_phone());

    // reply 
    let encode:Vec<u8> = msg_proto::encode_msg();
    let cmd:u32 = 123;
    let reply_package = glib::package(cmd, encode);

    // 直接发给客户端
    // let reply_package1 = reply_package.clone();
    println!("reply_package: {:?}", reply_package);
    client.framed.write(ChatResponse::Message(reply_package));

    // // 给其它在线的客户发个广播
    // ctx.state().addr.do_send(server::ClientMessageBin {
    //     id: client.id,
    //     msg: reply_package,
    //     room: client.room.clone(),
    // })

}
