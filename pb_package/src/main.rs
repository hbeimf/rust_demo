// extern crate protobuf;
// mod protos;


// fn main() {
//     println!("Hello, world!");
// }



extern crate protobuf;
extern crate byteorder;

// use byteorder::{ReadBytesExt, WriteBytesExt, BigEndian, LittleEndian};
use byteorder::{ReadBytesExt, WriteBytesExt, LittleEndian};


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

// fn test_package() {
//     package();
//     unpackage(); 
// }


fn package(cmd:u32, pb:Vec<u8>) -> Vec<u8> {
    println!("cmd: {}", cmd);
    println!("pb: {:?}", pb);

    let len:u32 = pb.len() as u32 + 4 + 4;
    let mut package = vec![];
    package.write_u32::<LittleEndian>(len).unwrap();
    package.write_u32::<LittleEndian>(cmd).unwrap();

    // let mut vec = vec![1];
    package.extend_from_slice(&pb);
    // assert_eq!(vec, [1, 2, 3, 4]);

    // println!("package: {:?}", package);
    // assert_eq!(wtr, vec![5, 2, 0, 3]);
    package
}


fn unpackage(package: Vec<u8>) {
    println!("unpackage: {:?}", package);
    use std::io::Cursor;
    // use byteorder::{BigEndian, ReadBytesExt};

    let mut rdr = Cursor::new(package);
    // Note that we use type parameters to indicate which kind of byte order
    // we want!
    // assert_eq!(517, rdr.read_u16::<BigEndian>().unwrap());
    // assert_eq!(768, rdr.read_u16::<BigEndian>().unwrap());

    let len = rdr.read_u32::<LittleEndian>().unwrap();
    let cmd = rdr.read_u32::<LittleEndian>().unwrap();
    println!("len:{} , cmd: {}", len, cmd);

}

