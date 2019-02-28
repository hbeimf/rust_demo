use protobuf::*;
use crate::protos;

//pub fn decode_login(pb:Vec<u8>) -> protos::msg::Login {
//    let login_msg : protos::msg::Login = parse_from_bytes::<protos::msg::Login>(&pb).unwrap();
//    login_msg
//}
//
//pub fn decode_msg(pb:Vec<u8>) -> protos::msg::TestMsg {
//    let test_msg : protos::msg::TestMsg = parse_from_bytes::<protos::msg::TestMsg>(&pb).unwrap();
//    test_msg
//}
//
//pub fn encode_msg() -> Vec<u8> {
//    let mut test_msg = protos::msg::TestMsg::new();
//    test_msg.set_name("tom".to_owned());
//    test_msg.set_nick_name("nick_name".to_owned());
//    test_msg.set_phone("15912341234".to_owned());
//
//    let msg :Vec<u8> = test_msg.write_to_bytes().unwrap();
//    msg
//}


pub fn decode_aes_en_package(pb:Vec<u8>) -> protos::msg::AesEncode {
    let aes_decode_obj : protos::msg::AesEncode = parse_from_bytes::<protos::msg::AesEncode>(&pb).unwrap();
    aes_decode_obj
}

pub fn decode_aes_de_package(pb:Vec<u8>) -> protos::msg::AesDecode {
    let aes_decode_obj : protos::msg::AesDecode = parse_from_bytes::<protos::msg::AesDecode>(&pb).unwrap();
    aes_decode_obj
}


pub fn encode_aes_de_reply(code:i32, reply_str:String) -> Vec<u8> {
    let mut reply = protos::msg::AesDecodeReply::new();
    reply.set_code(code);
    reply.set_reply(reply_str);

    let msg :Vec<u8> = reply.write_to_bytes().unwrap();
    msg
}