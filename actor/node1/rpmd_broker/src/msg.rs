use actix::prelude::*;

/// Send message to specific room
#[derive(Message)]
pub struct Message {
    pub id: u32,
    pub msg: Vec<u8>,
    pub room: String,
}


// work
#[derive(Message)]
pub struct RegisterBrokerWork{
    pub id: u32,
    pub addr: Recipient<PackageFromClient>,
}


#[derive(Message)]
pub struct UnregisterBrokerWork{
    
}

#[derive(Message, Debug)]
pub struct PackageFromClient(pub Vec<u8>);
