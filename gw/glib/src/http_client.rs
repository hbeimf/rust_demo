use curl::http::handle;
// use super::server;

use encoding::{Encoding, DecoderTrap};
use encoding::all::UTF_8;




// https://github.com/alexcrichton/curl-rust/blob/0.2.18/test/server.rs
pub fn get() {
	let res = handle()
	.get("https://www.baidu.com".to_string())
	.exec().unwrap();

	// srv.assert();

	// assert!(res.get_code() == 200, "code is {}", res.get_code());
	// assert!(res.get_body() == "Hello".as_bytes());
	// assert!(res.get_headers().len() == 1);
	// assert!(res.get_header("content-length") == ["5".to_string()]);
//	 println!("{:?}", res.get_body());

//	let body = String::from_utf8(res.get_body().to_vec());
//	println!("{:?}", body);


	let res = UTF_8.decode(res.get_body(), DecoderTrap::Strict);
	println!("res:{:?}", res);


}
