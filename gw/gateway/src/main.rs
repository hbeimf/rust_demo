extern crate actix;
extern crate mysqlc;
extern crate redisc;
extern crate tcp_server;
extern crate ws_server;

fn main() {
    mysqlc::test::test();
    redisc::test();

    let sys = actix::System::new("websocket-example");
    tcp_server::start_server();
    ws_server::start_server();
    let _ = sys.run();
}
