#![allow(unused_variables)]
extern crate byteorder;
extern crate bytes;
extern crate env_logger;
extern crate futures;
extern crate rand;
extern crate serde;
extern crate serde_json;
extern crate tokio_codec;
extern crate tokio_io;
extern crate tokio_tcp;
// #[macro_use]
extern crate serde_derive;

// #[macro_use]
extern crate actix;
extern crate actix_web;

#[macro_use] extern crate log;
// https://crates.io/crates/easy-logging

extern crate sys_config;
extern crate table;
extern crate glib;


pub mod broker_work;
pub mod msg;
pub mod broker_sup;
pub mod parse_package;
pub mod cmd;


use crate::broker_sup::{BrokerSupActor};
use actix::prelude::*;

use crate::msg::*;

pub fn start() {
    start_broker_sup();
}

fn start_broker_sup() {
    // warn!("start_broker_sup");
    let _act = System::current().registry().get::<BrokerSupActor>();
}

// 发送任意package 2 rpmd
pub fn send(package: Vec<u8>) {
    let send_package = SendPackage{
        package: package,
    };

    let broker_sup_addr = System::current().registry().get::<BrokerSupActor>();
    broker_sup_addr.do_send(send_package);
}