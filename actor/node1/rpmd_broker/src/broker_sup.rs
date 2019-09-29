use actix::prelude::*;
use std::collections::{HashMap};

pub use crate::msg::{Connect, Disconnect, Message, TableMessage, RegisterBrokerWork};
// pub use crate::msg::*;
use crate::broker_work;

// use rusqlite::types::ToSql;
// use rusqlite::{Connection, NO_PARAMS};

// #[derive(Debug)]
// struct Person {
//     id: i32,
//     uid: String,
//     room_id: String,
// }


//启动一个 rpmd tcp客户端,
// 监控连接的断开消息， 当连接断开的时候要尝试重连
// 收发来自连接上的消息
pub struct BrokerSupActor {
    sessions: HashMap<String, Recipient<TableMessage>>,
    // db: rusqlite::Connection,
}

impl Default for BrokerSupActor {
    fn default() -> BrokerSupActor {

        BrokerSupActor {
            sessions: HashMap::new(),
            // db: conn,
        }
    }
}

impl BrokerSupActor {
    fn broadcast_msg(&self, message: &Vec<u8>, _skip_id: u32) {

    }

}

impl Actor for BrokerSupActor {
    type Context = Context<Self>;
}

impl actix::Supervised for BrokerSupActor {}

impl SystemService for BrokerSupActor {
    // supvisor 启动回调函数，在这个地儿启动 rpmd tcp client 客户端 actor
    fn service_started(&mut self, _ctx: &mut Context<Self>) {
        println!("broker_sup 启动！ 在此处启动tcp 客户端  actor !!");
        broker_work::start();
    }
}

// supervisor 待处理消息逻辑  ================================================

impl Handler<Connect> for BrokerSupActor {
    type Result = u32;


    fn handle(&mut self, msg: Connect, _: &mut Context<Self>) -> Self::Result {

         self.sessions.insert(msg.uid.to_string(), msg.addr);

        // // insert sqlite
        // let room_id = 1;
        // self.db.execute(
        //     "INSERT INTO person (uid, room_id)
        //               VALUES (?1, ?2)",
        //     &[&msg.uid as &ToSql, &room_id],
        // ).unwrap();

        // // send id back
        // msg.uid
        32u32
    }
}

impl Handler<Disconnect> for BrokerSupActor {
    type Result = ();

    fn handle(&mut self, msg: Disconnect, _: &mut Context<Self>) {
        // info!("Disconnect, OUT  OUT  OUT  OUT  Someone disconnected room");

        // self.db.execute(
        //     "delete from person where uid = ?1",
        //     &[&msg.uid as &ToSql],
        // ).unwrap();

    }
}


impl Handler<RegisterBrokerWork> for BrokerSupActor {
    type Result = ();

    fn handle(&mut self, msg: RegisterBrokerWork, _: &mut Context<Self>) {
        // info!("Disconnect, OUT  OUT  OUT  OUT  Someone disconnected room");

        // self.db.execute(
        //     "delete from person where uid = ?1",
        //     &[&msg.uid as &ToSql],
        // ).unwrap();

    }
}

impl Handler<Message> for BrokerSupActor {
    type Result = ();

    fn handle(&mut self, msg: Message, _: &mut Context<Self>) {
        self.broadcast_msg(&msg.msg, msg.id);
    }
}


