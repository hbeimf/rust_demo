extern crate reqwest;

use encoding::{Encoding, DecoderTrap};
use encoding::all::{UTF_8, GBK};

//use std::collections::HashMap;

pub fn test() {
//    let resp = reqwest::get("https://httpbin.org/ip");
//
//    println!("{:#?}", resp);

    get_baidu();
    get_test();
}


// https://github.com/alexcrichton/curl-rust/blob/0.2.18/test/server.rs
//dns
//https://www.cnblogs.com/yudar/p/4723992.html
pub fn get_test() {
    let url = "http://quotes.money.163.com/service/chddata.html?code=0900919&start=20190101&end=20190121";

    let mut res = reqwest::get(url).unwrap();

//    let res = GBK.decode(res.get_body(), DecoderTrap::Strict);
//    println!("res:{:?}", res);

    println!("Status: {}", res.status());
    println!("Headers:\n{:?}", res.headers());

    let mut buf: Vec<u8> = vec![];
    let _result = res.copy_to(&mut buf);

    let body = GBK.decode(&buf, DecoderTrap::Strict);
    println!("body: {:?}", body);
}



pub fn get_baidu() {
    let url = "https://www.baidu.com";

    let mut res = reqwest::get(url).unwrap();

    println!("Status: {}", res.status());
    println!("Headers:\n{:?}", res.headers());

    let mut buf: Vec<u8> = vec![];
    let _result = res.copy_to(&mut buf);

    let body = UTF_8.decode(&buf, DecoderTrap::Strict);
    println!("body: {:?}", body);


}


// 上报
//[report_param]
//server_type = "1001"
//server_id = "100101"
//server_control_uri = "127.0.0.1:10006"
//max = 1000

//pub fn encode_report_server_info(server_type: String
//                                 ,server_id: String
//                                 ,server_uri: String
//                                 ,gwc_uri: String
//                                 , max: i32) -> Vec<u8> {
pub fn report_2_gwc() {
    let server_type = "10010";
    let server_id = "1001001";
    let gw_uri = "127.0.0.1:5566/ws/";
    let gwc_uri = "127.0.0.1:54321";

    let max = 1000;

    let pb = crate::pb::gwc_proto::encode_report_server_info(server_type.to_string(), server_id.to_string(), gw_uri.to_string(),gwc_uri.to_string(), max);

    let base64_str = crate::aes::encode_base64(pb);

    println!("base64: {:?}", base64_str);

    let url = "http://127.0.0.1:7788/report?ReportServerInfo=".to_owned() + &base64_str;
    println!("report url: {:?}", url);

    let mut res = reqwest::get(&url).unwrap();

    println!("Status: {}", res.status());
    println!("Headers:\n{:?}", res.headers());

    let mut buf: Vec<u8> = vec![];
    let _result = res.copy_to(&mut buf);

    let body = UTF_8.decode(&buf, DecoderTrap::Strict);
    println!("body: {:?}", body);

}