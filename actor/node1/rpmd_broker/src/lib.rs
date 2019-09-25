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

use crate::broker_sup::{BrokerSupActor};
use actix::prelude::*;


pub fn start() {
    start_broker_sup();
    broker_work::start();
}

fn start_broker_sup() {
    // warn!("start_broker_sup");
    let _act = System::current().registry().get::<BrokerSupActor>();
}