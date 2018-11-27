// extern crate protobuf;
// mod protos;


// fn main() {
//     println!("Hello, world!");
// }



extern crate protobuf;
extern crate byteorder;

use byteorder::{ReadBytesExt, WriteBytesExt, BigEndian, LittleEndian};

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

    package();
    unpackage();
}

// https://docs.rs/byteorder/1.2.7/byteorder/
// https://github.com/BurntSushi/byteorder

fn package() {
    let mut wtr = vec![];
    wtr.write_u16::<LittleEndian>(517).unwrap();
    wtr.write_u16::<LittleEndian>(768).unwrap();
    assert_eq!(wtr, vec![5, 2, 0, 3]);
}


fn unpackage() {
    use std::io::Cursor;
    // use byteorder::{BigEndian, ReadBytesExt};

    let mut rdr = Cursor::new(vec![2, 5, 3, 0]);
    // Note that we use type parameters to indicate which kind of byte order
    // we want!
    assert_eq!(517, rdr.read_u16::<BigEndian>().unwrap());
    assert_eq!(768, rdr.read_u16::<BigEndian>().unwrap());

}

