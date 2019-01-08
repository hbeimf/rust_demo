use byteorder::{ReadBytesExt, WriteBytesExt, LittleEndian};
use std::io::Cursor;


pub mod pb;
pub mod protos;


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
    let package_len:u32 = package.len() as u32;
    if package_len < 8u32 {
        None
    } else {
        let mut p1 = package.clone();
        
        let mut rdr = Cursor::new(package);
        let len:u32 = rdr.read_u32::<LittleEndian>().unwrap();
        let cmd:u32 = rdr.read_u32::<LittleEndian>().unwrap();

        if package_len != len {
            None
        } else {
            let pb:Vec<u8> = p1.split_off(8);
            // println!("len:{} , cmd: {}, pb: {:?}", len, cmd, pb);
            Some(UnPackageResult{len:len, cmd:cmd, pb:pb})
        }       
    }
}