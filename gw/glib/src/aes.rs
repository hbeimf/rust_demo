

use crate::openssl::aes::{AesKey, aes_ige};
use crate::openssl::symm::Mode;

//https://docs.rs/openssl/0.10.16/openssl/aes/index.html
pub fn test1() {
    let plaintext = b"\x12\x34\x56\x78\x90\x12\x34\x56\x12\x34\x56\x78\x90\x12\x34\x56";
    let en = encode(plaintext.to_vec());
    let de = decode(en);
    assert_eq!(plaintext.to_vec(), de);
}

pub fn test() {
//    let plaintext = b"\x12\x34\x56\x78\x90\x12\x34\x56\x12\x34\x56\x78\x90\x12\x34\x56";
    let plaintext = vec![1,2,3,4,5,6,7,8,9,0,11,12,13,14,15, 16, 1,2,3,4,5,6,7,8,9,0,11,12,13,14,15, 32];
    let en = encode(plaintext.clone());
    let de = decode(en);
//    assert_eq!(plaintext, de);

    dbg!(plaintext);
    dbg!(de);
}


pub fn decode(en: Vec<u8>) -> Vec<u8> {

    let key = key();
    let mut iv = iv();

    let key = AesKey::new_decrypt(&key).unwrap();
    let mut output = en.clone();
    aes_ige(&en, &mut output, &key, &mut iv, Mode::Decrypt);
    output.to_vec()

}

pub fn encode(plaintext:Vec<u8>) -> Vec<u8> {

    let key = key();
    let mut iv = iv();

    let key = AesKey::new_encrypt(&key).unwrap();
    let mut output = plaintext.clone();
    aes_ige(&plaintext, &mut output, &key, &mut iv, Mode::Encrypt);
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