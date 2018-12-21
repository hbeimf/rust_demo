extern crate actix;
// https://docs.rs/actix/0.7.9/actix/registry/struct.SystemRegistry.html
use actix::prelude::*;

#[derive(Message)]
struct Ping;

#[derive(Default)]
struct MyActor1{
	name:Option<String>
}

impl Actor for MyActor1 {
    type Context = Context<Self>;
}
impl actix::Supervised for MyActor1 {}

impl SystemService for MyActor1 {
    fn service_started(&mut self, _ctx: &mut Context<Self>) {
        println!("Service started");
    }
}

impl Handler<Ping> for MyActor1 {
    type Result = ();

    fn handle(&mut self, _: Ping, _ctx: &mut Context<Self>) {
        println!("ping");
        match self.name {
        	Some(ref name) => {
        		println!("使用：{:?}", name);		
        	},
        	None => {
        		println!("初始化");	
        		self.name = Some("小明".to_owned());
        	},
        }
        
    }
}

struct MyActor2;

impl Actor for MyActor2 {
    type Context = Context<Self>;

    fn started(&mut self, _: &mut Context<Self>) {
        let act = System::current().registry().get::<MyActor1>();
        act.do_send(Ping);
        
        let act1 = System::current().registry().get::<MyActor1>();
        act1.do_send(Ping);

    }
}

fn main() {
    // initialize system
    let _code = System::run(|| {
        // Start MyActor2
        let _addr = MyActor2.start();
    });
}