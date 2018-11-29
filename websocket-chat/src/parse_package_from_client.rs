use glib;
use handler_from_client::{WsChatSession, WsChatSessionState};
use actix_web::{ ws};
use server;

// 解包
pub fn parse_package(package: Vec<u8>, client: &mut WsChatSession, ctx: &mut ws::WebsocketContext<WsChatSession, WsChatSessionState>)  {

    let unpackage = glib::unpackage(package);

    match unpackage {
        Some(glib::UnPackageResult{len:_len, cmd, pb}) => {
            action(cmd, pb, client, ctx);
        }
        None => {
            println!("unpackage ");
        }
    }
}

// 业务逻辑部分
fn action(cmd:u32, pb:Vec<u8>, client: &mut WsChatSession, ctx: &mut ws::WebsocketContext<WsChatSession, WsChatSessionState>) {
	//parse pb logic 
	let test_msg = glib::decode_msg(pb);
    println!("name: {:?}", test_msg.get_name());
    println!("nick_name:{:?}", test_msg.get_nick_name());
    println!("phone: {:?}", test_msg.get_phone());

    // reply 
    let encode:Vec<u8> = glib::encode_msg();
    let cmd:u32 = 123;
    let reply_package = glib::package(cmd, encode);

    ctx.state().addr.do_send(server::ClientMessageBin {
        id: client.id,
        msg: reply_package,
        room: client.room.clone(),
    })

}
