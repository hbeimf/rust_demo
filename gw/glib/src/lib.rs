#![allow(unused_variables)]
extern crate byteorder;
extern crate bytes;
extern crate env_logger;
extern crate futures;
extern crate rand;
extern crate serde;
extern crate serde_json;
extern crate tokio_codec;
extern crate tokio_io;
extern crate tokio_tcp;
#[macro_use]
extern crate serde_derive;

#[macro_use]
extern crate actix;
extern crate actix_web;
#[macro_use] extern crate log;

use byteorder::{ReadBytesExt, WriteBytesExt, LittleEndian};
use std::io::Cursor;

pub mod pb;
pub mod protos;
pub mod codec;
//pub mod http_client;
//extern crate curl;
extern crate encoding;
extern crate openssl;
extern crate base64;

pub mod aes;

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
            Some(UnPackageResult{len:len, cmd:cmd, pb:pb})
        }       
    }
}