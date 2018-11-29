extern crate easy_logging;
#[macro_use] extern crate log;
// https://crates.io/crates/easy-logging

extern crate protobuf;
extern crate byteorder;

// use byteorder::{ReadBytesExt, WriteBytesExt, BigEndian, LittleEndian};
use byteorder::{ReadBytesExt, WriteBytesExt, LittleEndian};
use std::io::Cursor;
// use protobuf::Message;
use protobuf::*;
mod protos;

fn main() {
    // 初始化日志功能
    easy_logging::init(module_path!(), log::Level::Debug).unwrap();
    // easy_logging::init(module_path!(), log::Level::Info).unwrap();

    // debug!("Test debug message.");
    // info!("Test info message.");

	//encode
    let msg_pb :Vec<u8> = encode_msg();

    // package
    let cmd:u32 = 123456;
    let package = package(cmd, msg_pb);
    debug!("package: {:?}", package);

    // unpackage
    let unpackage = unpackage(package);
    match unpackage {
        Some(ResultPackage{len:_len, cmd:_cmd, pb}) => {
            // decode
            let test_msg = decode_msg(pb);
            debug!("name: {:?}", test_msg.get_name());
            debug!("nick_name:{:?}", test_msg.get_nick_name());
            debug!("phone: {:?}", test_msg.get_phone());



        }
        None => {
            println!("unpackage ");
        }
    }
}

fn decode_msg(pb:Vec<u8>) -> protos::msg::TestMsg {
    let test_msg : protos::msg::TestMsg = parse_from_bytes::<protos::msg::TestMsg>(&pb).unwrap();
    // println!("decode: {:?}", parsed);
    test_msg
}

fn encode_msg() -> Vec<u8> {
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

fn package(cmd:u32, pb:Vec<u8>) -> Vec<u8> {
    let len:u32 = pb.len() as u32 + 4 + 4;
    let mut package = vec![];
    package.write_u32::<LittleEndian>(len).unwrap();
    package.write_u32::<LittleEndian>(cmd).unwrap();
    package.extend_from_slice(&pb);
    package
}


pub struct ResultPackage {
    len:u32,
    cmd:u32,
    pb:Vec<u8>,
}

fn unpackage(package: Vec<u8>) -> Option<ResultPackage> {
    let mut p1 = package.clone();
    let pb:Vec<u8> = p1.split_off(8);

    let mut rdr = Cursor::new(package);
    let len:u32 = rdr.read_u32::<LittleEndian>().unwrap();
    let cmd:u32 = rdr.read_u32::<LittleEndian>().unwrap();
    info!("len:{} , cmd: {}, pb: {:?}", len, cmd, pb);
    Some(ResultPackage{len:len, cmd:cmd, pb:pb})
}

