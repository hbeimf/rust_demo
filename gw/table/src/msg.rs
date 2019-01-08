use actix::prelude::*;

#[derive(Message, Debug)]
pub struct TableMessage(pub Vec<u8>);

#[derive(Message)]
#[rtype(u32)]
pub struct Connect {
    pub uid: u32,
    pub addr: Recipient<TableMessage>,
}

// handler_cast()
#[derive(Message)]
pub struct Disconnect {
    pub uid: u32,
}

/// Send message to specific room
#[derive(Message)]
pub struct Message {
    pub id: u32,
    pub msg: Vec<u8>,
    pub room: String,
}
