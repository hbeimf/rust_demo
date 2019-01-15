#[macro_use]
extern crate log;
extern crate amqp;

extern crate sys_config;
extern crate glib;

mod receive;
pub use crate::receive::start_mq_client;

