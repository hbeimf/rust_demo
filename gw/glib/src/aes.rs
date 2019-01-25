

use crate::openssl::aes::{AesKey, aes_ige};
use crate::openssl::symm::Mode;

//https://docs.rs/openssl/0.10.16/openssl/aes/index.html
pub fn test() {

    let plaintext = b"\x12\x34\x56\x78\x90\x12\x34\x56\x12\x34\x56\x78\x90\x12\x34\x56";
//    dbg!(plaintext);

    let en = encode(plaintext);
    let de = decode(en);
//    dbg!(de);
    assert_eq!(*plaintext, de);
}

pub fn decode(en: [u8; 16]) -> [u8; 16] {
    let key = b"\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F";
    let mut iv = *b"\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\
                \x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F";

    let key = AesKey::new_decrypt(key).unwrap();
    let mut output = [0u8; 16];
    aes_ige(&en, &mut output, &key, &mut iv, Mode::Decrypt);
    output

}

pub fn encode(plaintext:&[u8; 16]) -> [u8; 16] {


    let key = b"\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F";
    let mut iv = *b"\x00\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0A\x0B\x0C\x0D\x0E\x0F\
                \x10\x11\x12\x13\x14\x15\x16\x17\x18\x19\x1A\x1B\x1C\x1D\x1E\x1F";

    let key = AesKey::new_encrypt(key).unwrap();
    let mut output = [0u8; 16];
    aes_ige(plaintext, &mut output, &key, &mut iv, Mode::Encrypt);
    output
}