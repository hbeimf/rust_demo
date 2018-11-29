// use byteorder::{ReadBytesExt, WriteBytesExt, LittleEndian};
// use std::io::Cursor;
use protobuf::*;

use super::protos;

pub fn decode_msg(pb:Vec<u8>) -> protos::msg::TestMsg {
    let test_msg : protos::msg::TestMsg = parse_from_bytes::<protos::msg::TestMsg>(&pb).unwrap();
    // println!("decode: {:?}", parsed);
    test_msg
}

pub fn encode_msg() -> Vec<u8> {
    let mut test_msg = protos::msg::TestMsg::new();
    test_msg.set_name("tom".to_owned());
    test_msg.set_nick_name("nick_name".to_owned());
    test_msg.set_phone("15912341234".to_owned());

    let msg :Vec<u8> = test_msg.write_to_bytes().unwrap();
    msg
}

