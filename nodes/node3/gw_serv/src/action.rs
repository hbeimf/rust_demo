extern crate tokio;
use futures::Future;

use glib;
use crate::gw_actor::{WsChatSession, WsChatSessionState};

use actix_web::{ ws};
use table;
use table::table_room::RoomActor;

use actix::*;
use glib::pb::msg_proto;

use crate::wsc;
use crate::tcpc;


// message Login{   
//     int32  uid = 1;
// }
// Login 
pub fn action_10000(cmd:u32, pb:Vec<u8>, package: Vec<u8>
    , client: &mut WsChatSession
    , ctx: &mut ws::WebsocketContext<WsChatSession, WsChatSessionState>) {
    //parse pb logic 
    let login_msg = msg_proto::decode_login(pb);
    debug!("uid: {:?}", login_msg.get_uid());
    
    let uid = login_msg.get_uid();

    client.uid = uid as u32;

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



    // // handler_cast()
    // // 给其它在线的客户发个广播
    // ctx.state().addr.do_send(room::Message {
    //     id: client.id,
    //     msg: reply_package,
    //     room: client.room.clone(),
    // })

    match client.addr_wsc {
        Some(ref the_addr_wsc) => {
            // debug!("与后端已经建立了wsc连接， 直接使用就可以了！！！！！！！！！");
            let package_from_client = wsc::gen_server::PackageFromClient(package.clone());
            the_addr_wsc.do_send(package_from_client);
            
        },
        _ => {
            // 当没有与后端节点的连接时，建立一个连接  ctx.address()
            // debug!("还没建立wsc连接, 现在马上建立一个!!");
            // let addr_wsc = ctx.address();
            let addr = ctx.address();
            wsc::gen_server::start_wsc(addr);
        }
    };


    match client.addr_tcpc {
        Some(ref the_addr_tcpc) => {
            // debug!("与后端已经建立了tcpc连接， 直接使用就可以了！！！！！！！！！");
            let package_from_client = tcpc::PackageFromClient(package.clone());
            the_addr_tcpc.do_send(package_from_client);
        },
        _ => {
            // 当没有与后端节点的连接时，建立一个连接  ctx.address()
            // debug!("还没建立tcpc连接, 现在马上建立一个!!");
            let addr = ctx.address();
            // tcp 客户端测试
            tcpc::start_tcpc(addr);
        }
    };

}

// 业务逻辑部分
pub fn action(cmd:u32, pb:Vec<u8>, package: Vec<u8>
    , client: &mut WsChatSession
    , ctx: &mut ws::WebsocketContext<WsChatSession, WsChatSessionState>) {

    // reply 
    let encode:Vec<u8> = msg_proto::encode_msg();
    let cmd:u32 = 123;
    let reply_package = glib::package(cmd, encode);

    // 直接发给客户端
    let reply_package1 = reply_package.clone();
    ctx.binary(reply_package1);
    ctx.text("hello".to_owned());

    let act = System::current().registry().get::<RoomActor>();
    act.do_send(table::table_room::Message {
        id: client.uid,
        msg: reply_package,
        room: client.room.clone(),
    })
}
