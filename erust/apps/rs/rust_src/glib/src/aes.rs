

use crate::openssl::aes::{AesKey, aes_ige};
use crate::openssl::symm::Mode;

use crate::base64::{encode as encode_b64, decode as decode_b64};
use crate::md5;

//https://docs.rs/openssl/0.10.16/openssl/aes/index.html
pub fn test() {
    test1();
}


fn test1() {
    let s = String::from("hello");
    let key = String::from("201707eggplant99");

    let en = encode(s.clone(), key.clone());
    dbg!(en.clone());

    let de = decode(en, key).unwrap();
    dbg!(de);
}


pub fn encode_base64(en: Vec<u8>) -> String {
    encode_b64(&en)
}

pub fn decode_base64(b64: String) -> std::result::Result<std::vec::Vec<u8>, base64::DecodeError> {
    decode_b64(&b64)
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


pub fn decode(en: String, key: String) -> Option<String> {
    match decode_base64(en) {
        Ok(v) => {
            let de = decode_vec(v, key);
            let from = String::from_utf8(de);
            match from {
                Ok(s) => {
                    Some(s)
                }
                _ => {
                    None
                }
            }
        }
        _ => {
            None
        }
    }
}

pub fn decode_vec(en: Vec<u8>, key:String) -> Vec<u8> {
    let key = get_key(key);
    let mut iv = iv();

    let key = AesKey::new_decrypt(&key).unwrap();
    let mut output = en.clone();
    aes_ige(&en, &mut output, &key, &mut iv, Mode::Decrypt);
    let output = output.to_vec();

    let len = output.len();
    let last = output[len - 1] as usize;

    if last < len {
        let split_pos = len - last;
        let (left, _) = output.split_at(split_pos);
        let res = left.to_vec();
        res
    } else {
        output
    }
}

pub fn encode(from_str:String, key:String) -> String {
    let from_v8 = from_str.into_bytes();
    let key = get_key(key);
    let en = encode_vec(from_v8, key);
    encode_b64(&en)
}

pub fn encode_vec(from_v8:Vec<u8>, key:Vec<u8>) -> Vec<u8> {
    let mut from_str = from_v8;
    let n = (16 - from_str.len()) as u8;
    let mut padding = get_padding(n);

    from_str.append(&mut padding);

//    let key = key();
    let mut iv = iv();

    let key = AesKey::new_encrypt(&key).unwrap();
    let mut output = from_str.clone();
    aes_ige(&from_str, &mut output, &key, &mut iv, Mode::Encrypt);
    output.to_vec()
}

fn get_key(key:String) -> Vec<u8> {
//    let key = "201707eggplant99".to_string();
//    key.into_bytes()

    let digest = md5::compute(key.clone());
    let mut md5_encode = digest.as_ref().to_owned();
    md5_encode.truncate(16);
    md5_encode
}

fn iv() -> Vec<u8> {
    let iv = "12345678901234561234567890123456".to_string();
    iv.into_bytes()
}