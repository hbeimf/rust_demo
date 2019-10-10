use actix::prelude::*;
use std::collections::{HashMap};

pub use crate::msg::*;
use crate::broker_work;


//启动一个 rpmd tcp客户端,
// 监控连接的断开消息， 当连接断开的时候要尝试重连
// 收发来自连接上的消息
pub struct BrokerSupActor {
    works_addr_map: HashMap<String, Recipient<SendPackage>>,
    // db: rusqlite::Connection,
}

impl Default for BrokerSupActor {
    fn default() -> BrokerSupActor {

        BrokerSupActor {
            works_addr_map: HashMap::new(),
            // db: conn,
        }
    }
}

impl BrokerSupActor {
    // 遍历 sessions , 发送pakcage
    fn broadcast_package(&self, send_package: SendPackage) {
        for (key, addr) in &self.works_addr_map {
            println!("broadcast package: {:?}", send_package);
            let _ = addr.do_send(send_package.clone());
        }
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


impl Handler<RegisterBrokerWork> for BrokerSupActor {
    type Result = ();

    fn handle(&mut self, msg: RegisterBrokerWork, _: &mut Context<Self>) {
        // info!("Disconnect, OUT  OUT  OUT  OUT  Someone disconnected room");
        println!(" register broker work!!");
        self.works_addr_map.insert(msg.id.to_string(), msg.addr);

        // 当连接已经建立了，发送测试包
         crate::test_send();

    }
}

//UnregisterBrokerWork
impl Handler<UnregisterBrokerWork> for BrokerSupActor {
    type Result = ();

    fn handle(&mut self, msg: UnregisterBrokerWork, _: &mut Context<Self>) {
        self.works_addr_map.remove(&msg.id.to_string());
        // 启重一个新的 work
        broker_work::start();
    }
}

impl Handler<SendPackage> for BrokerSupActor {
    type Result = ();

    fn handle(&mut self, send_package: SendPackage, _: &mut Context<Self>) {
//        println!(" send package: {:?}", send_package);
        self.broadcast_package(send_package);
    }
}
