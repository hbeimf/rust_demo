// extern crate protobuf;
// mod protos;


// fn main() {
//     println!("Hello, world!");
// }



extern crate protobuf;

use protobuf::Message;
mod protos;

fn main() {
    let mut test_msg = protos::msg::TestMsg::new();
    test_msg.set_name("tom".to_owned());
    test_msg.set_nick_name("nick_name".to_owned());
    test_msg.set_phone("15912341234".to_owned());

    let serialized :Vec<u8> = test_msg.write_to_bytes().unwrap();
    println!("{:?}", serialized);
}
