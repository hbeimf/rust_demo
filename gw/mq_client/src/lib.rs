#[macro_use]
extern crate log;
extern crate amqp;

extern crate sys_config;

mod receive;
pub use crate::receive::start_mq_client;

