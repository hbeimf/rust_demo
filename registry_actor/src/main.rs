extern crate actix;
extern crate futures;
extern crate tokio;
// https://docs.rs/actix/0.7.9/actix/registry/struct.SystemRegistry.html
use actix::prelude::*;
// use actix::*;
// use actix::ActorContext;
use futures::Future;

#[derive(Message)]
struct CastMsg;

// #[derive(Message)]
// #[rtype(String)]
struct CallMsg;

impl Message for CallMsg {
    type Result = String;
}


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

impl Handler<CastMsg> for MyActor1 {
    type Result = ();

    fn handle(&mut self, _: CastMsg, _ctx: &mut Context<Self>) {
        println!("CastMsg");
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

impl Handler<CallMsg> for MyActor1 {
    type Result = String;

    fn handle(&mut self, _: CallMsg, _ctx: &mut Context<Self>) -> Self::Result {
        println!("CallMsg");
        match self.name {
        	Some(ref name) => {
        		println!("使用：{:?}", name);	
        		name.to_string()	
        	},
        	None => {
        		println!("初始化");	
        		self.name = Some("小明".to_owned());
        		"小明".to_owned()
        	},
        }

    }
}

struct MyActor2;

impl Actor for MyActor2 {
    type Context = Context<Self>;

    fn started(&mut self, _ctx: &mut Context<Self>) {
        let act = System::current().registry().get::<MyActor1>();
        act.do_send(CastMsg);
        
        let act1 = System::current().registry().get::<MyActor1>();
        act1.do_send(CastMsg);
        let res = act1.send(CallMsg);
        
        // handle() returns tokio handle
        tokio::spawn(
            res.map(|res| {
                println!("call result: {:?}", res);

                // stop system and exit
                // System::current().stop();
            }).map_err(|_| ()),
        );

    }
}

fn main() {
    // initialize system
    let _code = System::run(|| {
        // Start MyActor2
        let _addr = MyActor2.start();
    });
}