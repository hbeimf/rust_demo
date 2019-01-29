extern crate reqwest;

//use std::collections::HashMap;

pub fn test() {
    let resp = reqwest::get("https://httpbin.org/ip");

    println!("{:#?}", resp);
}