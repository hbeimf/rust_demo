use actix::prelude::*;
// use rand::{self, Rng, ThreadRng};
// use std::cell::RefCell;
// use std::collections::{HashMap, HashSet};

use tcps::session;

/// Message for chat server communications

// /// New chat session is created
#[derive(Message)]
#[rtype(u32)]
pub struct Connect {
    pub uid: u32,
    pub addr: Recipient<session::Message>,
}

// #[derive(Message)]
// pub struct Connect {
//     pub uid: u32,
//     pub addr: Recipient<session::Message>,
// }

/// Session is disconnected
#[derive(Message)]
pub struct Disconnect {
    pub id: u32,
}

/// Send message to specific room
#[derive(Message)]
pub struct Message {
    /// Id of the client session
    pub id: u32,
    /// Peer message
    pub msg: Vec<u8>,
    /// Room name
    pub room: String,
}

/// Send message to specific room
#[derive(Message)]
pub struct ClientMessageBin {
    /// Id of the client session
    pub id: u32,
    /// Peer message
    pub msg: Vec<u8>,
    /// Room name
    pub room: String,
}

// /// List of available rooms
// pub struct ListRooms;

// impl actix::Message for ListRooms {
//     type Result = Vec<String>;
// }

// /// Join room, if room does not exists create new one.
// #[derive(Message)]
// pub struct Join {
//     /// Client id
//     pub id: u32,
//     /// Room name
//     pub name: String,
// }