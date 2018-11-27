// extern crate protobuf;
// mod protos;


// fn main() {
//     println!("Hello, world!");
// }



extern crate protobuf;
extern crate byteorder;

// use byteorder::{ReadBytesExt, WriteBytesExt, BigEndian, LittleEndian};
use byteorder::{ReadBytesExt, WriteBytesExt, LittleEndian};
use std::io::Cursor;
// use protobuf::Message;
use protobuf::*;
mod protos;

fn main() {
	//encode
    let mut test_msg = protos::msg::TestMsg::new();
    test_msg.set_name("tom".to_owned());
    test_msg.set_nick_name("nick_name".to_owned());
    test_msg.set_phone("15912341234".to_owned());

    let serialized :Vec<u8> = test_msg.write_to_bytes().unwrap();
    println!("encode: {:?}", serialized);

    // decode 
    let parsed = parse_from_bytes::<protos::msg::TestMsg>(&serialized).unwrap();
    println!("decode: {:?}", parsed);

    // test_package();
    let cmd:u32 = 123456;
    let package = package(cmd, serialized);
    println!("package: {:?}", package);

    unpackage(package);
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


fn unpackage(package: Vec<u8>) {
    let mut rdr = Cursor::new(package);
    let len = rdr.read_u32::<LittleEndian>().unwrap();
    let cmd = rdr.read_u32::<LittleEndian>().unwrap();
    println!("len:{} , cmd: {}, pb: {:?}", len, cmd, rdr);

}

