// extern crate protobuf;
// mod protos;


// fn main() {
//     println!("Hello, world!");
// }



extern crate protobuf;

use protobuf::Message;
mod protos;

fn main() {
    let mut animal = protos::msg::TestMsg::new();
    animal.set_name("tom".to_owned());
    animal.set_nick_name("nick_name".to_owned());
    animal.set_phone("15912341234".to_owned());

    let serialized :Vec<u8> = animal.write_to_bytes().unwrap();
    println!("{:?}", serialized);
}
