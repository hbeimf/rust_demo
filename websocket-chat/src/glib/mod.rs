use byteorder::{ReadBytesExt, WriteBytesExt, LittleEndian};
use std::io::Cursor;
use protobuf::*;

use super::protos;




pub fn test() {
	//encode
    let msg_pb :Vec<u8> = encode_msg();

    // package
    let cmd:u32 = 123456;
    let package = package(cmd, msg_pb);
    println!("package: {:?}", package);

    // unpackage
    let unpackage = unpackage(package);
    match unpackage {
        Some(UnPackageResult{len:_len, cmd:_cmd, pb}) => {
            // decode
            let test_msg = decode_msg(pb);
            println!("name: {:?}", test_msg.get_name());
            println!("nick_name:{:?}", test_msg.get_nick_name());
            println!("phone: {:?}", test_msg.get_phone());

        }
        None => {
            println!("unpackage ");
        }
    }
}


// pub fn test_unpackage(package: Vec<u8>) {
//     let unpackage = unpackage(package);
//     match unpackage {
//         Some(UnPackageResult{len:_len, cmd:_cmd, pb}) => {
//             // decode
//             let test_msg = decode_msg(pb);
//             println!("name: {:?}", test_msg.get_name());
//             println!("nick_name:{:?}", test_msg.get_nick_name());
//             println!("phone: {:?}", test_msg.get_phone());

//         }
//         None => {
//             println!("unpackage ");
//         }
//     }
// }

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

// https://docs.rs/byteorder/1.2.7/byteorder/
// https://github.com/BurntSushi/byteorder
// http://blog.zhukunqian.com/?cat=32

pub fn package(cmd:u32, pb:Vec<u8>) -> Vec<u8> {
    let len:u32 = pb.len() as u32 + 4 + 4;
    let mut package = vec![];
    package.write_u32::<LittleEndian>(len).unwrap();
    package.write_u32::<LittleEndian>(cmd).unwrap();
    package.extend_from_slice(&pb);
    package
}


pub struct UnPackageResult {
    pub len:u32,
    pub cmd:u32,
    pub pb:Vec<u8>,
}

pub fn unpackage(package: Vec<u8>) -> Option<UnPackageResult> {
    let mut p1 = package.clone();
    let pb:Vec<u8> = p1.split_off(8);

    let mut rdr = Cursor::new(package);
    let len:u32 = rdr.read_u32::<LittleEndian>().unwrap();
    let cmd:u32 = rdr.read_u32::<LittleEndian>().unwrap();
    println!("len:{} , cmd: {}, pb: {:?}", len, cmd, pb);
    Some(UnPackageResult{len:len, cmd:cmd, pb:pb})
}