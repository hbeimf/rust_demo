use glib;
use wss::handler::{WsChatSession, WsChatSessionState};
use wss::action;

use actix_web::{ ws};
// use hub::room;
use actix::ActorContext;
// use actix::*;
// use pb::msg_proto;

// use wsc;
// use tcpc;

// use actix::prelude::Request;


// 解包
pub fn parse_package(package: Vec<u8>, client: &mut WsChatSession, ctx: &mut ws::WebsocketContext<WsChatSession, WsChatSessionState>)  {
    // let _addr = ctx.address();
    let unpackage = glib::unpackage(package.clone());

    match unpackage {
        Some(glib::UnPackageResult{len:_len, cmd, pb}) => {
            match cmd {
                10000 => {
                    action::action_10000(cmd, pb, package, client, ctx);
                }
                _ => {
                    action::action(cmd, pb, package, client, ctx);   
                }
            }
            // action(cmd, pb, package, client, ctx);
        }
        None => {
        	// 如果解包失败，直接关掉连接
            debug!("unpackage error ...");
            ctx.stop();
        }
    }
}

