use curl::http::handle;
// use super::server;

use encoding::{Encoding, DecoderTrap};
use encoding::all::GBK;




// https://github.com/alexcrichton/curl-rust/blob/0.2.18/test/server.rs
pub fn get() {
	let url = "http://quotes.money.163.com/service/chddata.html?code=0900919&start=20000101&end=20190121".to_string();

	let res = handle()
	.get(url)
	.exec().unwrap();

//	let res = handle()
//		.get("https://www.baidu.com".to_string())
//		.exec().unwrap();


	// srv.assert();

	// assert!(res.get_code() == 200, "code is {}", res.get_code());
	// assert!(res.get_body() == "Hello".as_bytes());
	// assert!(res.get_headers().len() == 1);
	// assert!(res.get_header("content-length") == ["5".to_string()]);
//	 println!("{:?}", res.get_body());

//	let body = String::from_utf8(res.get_body().to_vec());
//	println!("{:?}", body);


	let res = GBK.decode(res.get_body(), DecoderTrap::Strict);
	println!("res:{:?}", res);


}
