use glib;


pub fn parse_package(package: Vec<u8>, ctx: ws::WebsocketContext<WsChatSession, WsChatSessionState>)  {
	glib::test();

	println!("============================== ");

	let unpackage = glib::unpackage(package);
	// println!("binary message {:?}", unpackage);

    match unpackage {
        Some(glib::ResultPackage{len:_len, cmd:_cmd, pb}) => {
            // decode
            let test_msg = glib::decode_msg(pb);
            println!("name: {:?}", test_msg.get_name());
            println!("nick_name:{:?}", test_msg.get_nick_name());
            println!("phone: {:?}", test_msg.get_phone());

        }
        None => {
            println!("unpackage ");
        }
    }

}

