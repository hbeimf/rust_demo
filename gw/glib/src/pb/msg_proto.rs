use protobuf::*;

use crate::protos;


pub fn decode_login(pb:Vec<u8>) -> protos::msg::Login {
    let login_msg : protos::msg::Login = parse_from_bytes::<protos::msg::Login>(&pb).unwrap();
    // println!("decode: {:?}", parsed);
    login_msg
}


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


pub fn decode_rpc(pb:Vec<u8>) -> protos::msg::RpcPackage {
    let rpc_msg : protos::msg::RpcPackage = parse_from_bytes::<protos::msg::RpcPackage>(&pb).unwrap();
    rpc_msg
}

pub fn encode_rpc(key: String, payload: Vec<u8>) -> Vec<u8> {
    let mut rpc_msg = protos::msg::RpcPackage::new();
    rpc_msg.set_key(key);
    rpc_msg.set_payload(payload);

    let msg :Vec<u8> = rpc_msg.write_to_bytes().unwrap();
    msg
}
