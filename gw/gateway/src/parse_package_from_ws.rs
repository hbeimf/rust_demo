use glib;
use handler_from_client_ws::{WsChatSession, WsChatSessionState};
use actix_web::{ ws};
use server;
use actix::ActorContext;
use actix::*;
use msg_proto;

use wsc;

// 解包
pub fn parse_package(package: Vec<u8>, client: &mut WsChatSession, ctx: &mut ws::WebsocketContext<WsChatSession, WsChatSessionState>)  {
    // let _addr = ctx.address();
    let unpackage = glib::unpackage(package.clone());

    match unpackage {
        Some(glib::UnPackageResult{len:_len, cmd, pb}) => {
            action(cmd, pb, package, client, ctx);
        }
        None => {
        	// 如果解包失败，直接关掉连接
            debug!("unpackage error ...");
            ctx.stop();
        }
    }
}

// 业务逻辑部分
fn action(cmd:u32, pb:Vec<u8>, package: Vec<u8>, client: &mut WsChatSession, ctx: &mut ws::WebsocketContext<WsChatSession, WsChatSessionState>) {
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
    let reply_package1 = reply_package.clone();
    ctx.binary(reply_package1);
    ctx.text("hello".to_owned());

    match client.addr_wsc {
        Some(ref the_addr_wsc) => {
            debug!("与后端已经建立了wsc连接， 直接使用就可以了！！！！！！！！！");
            let package_from_client = wsc::PackageFromClient(package);
            the_addr_wsc.do_send(package_from_client);
        },
        _ => {
            // 当没有与后端节点的连接时，建立一个连接  ctx.address()
            debug!("还没建立wsc连接, 现在马上建立一个!!");
            // let addr_wsc = ctx.address();
            let addr = ctx.address();
            wsc::start_wsc(addr);
        }
    };


    // 给其它在线的客户发个广播
    ctx.state().addr.do_send(server::ClientMessageBin {
        id: client.id,
        msg: reply_package,
        room: client.room.clone(),
    })

}
