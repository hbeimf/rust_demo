use glib;
use handler_from_client::{WsChatSession, WsChatSessionState};
use actix_web::{ ws};
use server;

pub fn parse_package(package: Vec<u8>, client: &mut WsChatSession, ctx: &mut ws::WebsocketContext<WsChatSession, WsChatSessionState>)  {
    glib::test();

    println!("============================== ");
    let package1 = package.clone();
    let unpackage = glib::unpackage(package1);
    // println!("binary message {:?}", unpackage);

    match unpackage {
        Some(glib::ResultPackage{len:_len, cmd:_cmd, pb}) => {
            // decode
            let test_msg = glib::decode_msg(pb);
            println!("name: {:?}", test_msg.get_name());
            println!("nick_name:{:?}", test_msg.get_nick_name());
            println!("phone: {:?}", test_msg.get_phone());

        }
        None => {
            println!("unpackage ");
        }
    }

    ctx.state().addr.do_send(server::ClientMessageBin {
        id: client.id,
        msg: package,
        room: client.room.clone(),
    })

}
