//#[macro_use]
//extern crate log;
//extern crate amqp;

use amqp::{Basic, Session, Channel, Table, protocol};
// use std::default::Default;
use std::thread;

use sys_config;
//table types:
//use table::{FieldTable, Table, Bool, ShortShortInt, ShortShortUint, ShortInt, ShortUint, LongInt, LongUint, LongLongInt, LongLongUint, Float, Double, DecimalValue, LongString, FieldArray, Timestamp};

fn consumer_function(channel: &mut Channel, deliver: protocol::basic::Deliver, headers: protocol::basic::BasicProperties, body: Vec<u8>) {
    debug!("Got a delivery:");
    debug!("Deliver info: {:?}", deliver);
    debug!("Content headers: {:?}", headers);
    debug!("Content body: {:?}", body);

//    let b = String::from_utf8(body).unwrap();
//    debug!("body: {:?}", b);
    println!("body: {:?}", body);


    let _res = channel.basic_ack(deliver.delivery_tag, false);
}



pub fn start_mq_client() {

    debug!("start mq client !");

    let rabbit_config = sys_config::config_rabbit();

    let mut session = match Session::open_url(rabbit_config.as_ref()) {
        Ok(session) => session,
        Err(error) => panic!("Can't create session: {:?}", error)
    };
    let mut channel = session.open_channel(1).ok().expect("Can't open channel");
    debug!("Openned channel: {}", channel.id);

    let queue_name = "test_queue";
    //queue: &str, passive: bool, durable: bool, exclusive: bool, auto_delete: bool, nowait: bool, arguments: Table
    let queue_declare = channel.queue_declare(queue_name, false, true, false, false, false, Table::new());
    debug!("Queue declare: {:?}", queue_declare);
    for get_result in channel.basic_get(queue_name, false) {
        debug!("Headers: {:?}", get_result.headers);
        debug!("Reply: {:?}", get_result.reply);
        debug!("Body: {:?}", String::from_utf8_lossy(&get_result.body));
        get_result.ack();
    }

    //queue: &str, consumer_tag: &str, no_local: bool, no_ack: bool, exclusive: bool, nowait: bool, arguments: Table
    debug!("Declaring consumer...");
    let consumer_name = channel.basic_consume(consumer_function, queue_name, "", false, false, false, false, Table::new());
    debug!("Starting consumer {:?}", consumer_name);

    let consumers_thread = thread::spawn(move || {
        channel.start_consuming();
        channel
    });

    // There is currently no way to stop the consumers, so we infinitely join thread.
    let mut _channel = consumers_thread.join().ok().expect("Can't get channel from consumer thread");
    debug!("如果运行到这里，就代表连接已经断开了 !!");
    // 如果断开了，就给supervisor 发个消息，让他重启一个消费者进程

    // let _res = channel.basic_publish("", queue_name, true, false,
    //     protocol::basic::BasicProperties{ content_type: Some("text".to_string()), ..Default::default()},
    //     (b"Hello from rust!").to_vec());
    // let _rr = channel.close(200, "Bye");
    // session.close(200, "Good Bye");
}
