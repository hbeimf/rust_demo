

use crate::openssl::aes::{AesKey, aes_ige};
use crate::openssl::symm::Mode;

//https://docs.rs/openssl/0.10.16/openssl/aes/index.html
pub fn test() {
    test1();
}


fn test1() {
    let s = String::from("1234567");

    let en = encode_str(s.clone());
    let de = decode(en);

    let sparkle_heart = String::from_utf8(de).unwrap();
    dbg!(sparkle_heart);

}


fn get_padding(n:u8) -> Vec<u8> {
    if n == 0 {
        let mut vec = Vec::with_capacity(16);
        for i in 0..16
        {
            vec.push(16);
        }
        vec
    } else {
        let mut vec = Vec::with_capacity(n as usize);
        for i in 0..n
        {
            vec.push(n);
        }
        vec
    }
}


pub fn decode(en: Vec<u8>) -> Vec<u8> {
    let key = key();
    let mut iv = iv();

    let key = AesKey::new_decrypt(&key).unwrap();
    let mut output = en.clone();
    aes_ige(&en, &mut output, &key, &mut iv, Mode::Decrypt);
    let output = output.to_vec();

    let len = output.len();
    let last = output[len - 1] as usize;
    let split_pos = len - last;

    let (left, _) = output.split_at(split_pos);
    let res = left.to_vec();
    res
}

pub fn encode_str(from_str:String) -> Vec<u8> {
    let from_v8 = from_str.into_bytes();
    encode(from_v8)
}

pub fn encode(from_v8:Vec<u8>) -> Vec<u8> {
    let mut from_str = from_v8;
    let n = (16 - from_str.len()) as u8;
    let mut padding = get_padding(n);

    from_str.append(&mut padding);

    let key = key();
    let mut iv = iv();

    let key = AesKey::new_encrypt(&key).unwrap();
    let mut output = from_str.clone();
    aes_ige(&from_str, &mut output, &key, &mut iv, Mode::Encrypt);
    output.to_vec()
}

fn key() -> Vec<u8> {
    let key = b"\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F";
    key.to_vec()
}

fn iv() -> Vec<u8> {
    let iv = *b"\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\
                \x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F";
    iv.to_vec()
}