use protobuf::*;
use crate::protos;


pub fn decode_msg(pb:Vec<u8>) -> protos::msg::Msg {
    let msg : protos::msg::Msg = parse_from_bytes::<protos::msg::Msg>(&pb).unwrap();
    msg
}

pub fn encode_msg(cmd: i32, payload: Vec<u8>) -> Vec<u8> {
    let mut msg = protos::msg::Msg::new();
    // rpc_msg.set_key(key);
    msg.set_cmd(cmd);
    msg.set_payload(payload);

    let reply_msg :Vec<u8> = msg.write_to_bytes().unwrap();
    reply_msg
}
