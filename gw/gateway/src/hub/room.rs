//! `RoomActor` is an actor. It maintains list of connection client session.
//! And manages available rooms. Peers send messages to other peers in same
//! room through `RoomActor`.

use actix::prelude::*;
// use rand::{self, Rng};
// use rand::{self, Rng, ThreadRng};

// use std::cell::RefCell;
use std::collections::{HashMap, HashSet};
use tcps::session;
pub use hub::msg_room::{Connect, Disconnect, Message};

// use actix::prelude::Request;


// pub fn get_uid() -> u32 {
//     let rng = RefCell::new(rand::thread_rng());
//     let id = rng.borrow_mut().gen::<u32>();
//     id
// }

/// `RoomActor` manages chat rooms and responsible for coordinating chat
/// session. implementation is super primitive
pub struct RoomActor {
    sessions: HashMap<u32, Recipient<session::Message>>,
    rooms: HashMap<String, HashSet<u32>>,
    // rng: RefCell<ThreadRng>,
}

impl Default for RoomActor {
    fn default() -> RoomActor {
        // default room
        let mut rooms = HashMap::new();
        rooms.insert("Main".to_owned(), HashSet::new());

        RoomActor {
            sessions: HashMap::new(),
            rooms: rooms,
            // rng: RefCell::new(rand::thread_rng()),
        }
    }
}

impl RoomActor {
    fn send_message(&self, room: &str, message: &Vec<u8>, skip_id: u32) {
        if let Some(sessions) = self.rooms.get(room) {
            for id in sessions {
                if *id != skip_id {
                    if let Some(addr) = self.sessions.get(id) {
                        let _ = addr.do_send(session::Message(message.to_vec()));
                    }
                }
            }
        }
    }
}

/// Make actor from `RoomActor`
impl Actor for RoomActor {
    /// We are going to use simple Context, we just need ability to communicate
    /// with other actors.
    type Context = Context<Self>;
}

/// Handler for Connect message.
///
/// Register new session and assign unique id to this session
impl Handler<Connect> for RoomActor {
    type Result = u32;

    fn handle(&mut self, msg: Connect, _: &mut Context<Self>) -> Self::Result {
        debug!("Someone joined room");

        // notify all users in same room
        // self.send_message(&"Main".to_owned(), "Someone joined", 0);

        // register session with random id
        // let id = self.rng.borrow_mut().gen::<u32>();

        self.sessions.insert(msg.uid, msg.addr);

        // auto join session to Main room
        self.rooms.get_mut(&"Main".to_owned()).unwrap().insert(msg.uid);

        // send id back
        msg.uid
    }
}

/// Handler for Disconnect message.
impl Handler<Disconnect> for RoomActor {
    type Result = ();

    fn handle(&mut self, msg: Disconnect, _: &mut Context<Self>) {
        debug!("Someone disconnected room");

        let mut rooms: Vec<String> = Vec::new();

        // remove address
        if self.sessions.remove(&msg.id).is_some() {
            // remove session from all rooms
            for (name, sessions) in &mut self.rooms {
                if sessions.remove(&msg.id) {
                    rooms.push(name.to_owned());
                }
            }
        }
        // // send message to other users
        // for room in rooms {
        //     self.send_message(&room, "Someone disconnected", 0);
        // }
    }
}

/// Handler for Message message.
impl Handler<Message> for RoomActor {
    type Result = ();

    fn handle(&mut self, msg: Message, _: &mut Context<Self>) {
        // self.send_message(&msg.room, msg.msg.as_str(), msg.id);
        self.send_message(&msg.room, &msg.msg, msg.id);

    }
}


// /// Handler for Message message.
// impl Handler<ClientMessageBin> for RoomActor {
//     type Result = ();

//     fn handle(&mut self, msg: ClientMessageBin, _: &mut Context<Self>) {
//         self.send_message(&msg.room, &msg.msg, msg.id);
//     }
// }


// /// Handler for `ListRooms` message.
// impl Handler<ListRooms> for RoomActor {
//     type Result = MessageResult<ListRooms>;

//     fn handle(&mut self, _: ListRooms, _: &mut Context<Self>) -> Self::Result {
//         let mut rooms = Vec::new();

//         for key in self.rooms.keys() {
//             rooms.push(key.to_owned())
//         }

//         MessageResult(rooms)
//     }
// }

// /// Join room, send disconnect message to old room
// /// send join message to new room
// impl Handler<Join> for RoomActor {
//     type Result = ();

//     fn handle(&mut self, msg: Join, _: &mut Context<Self>) {
//         let Join { id, name } = msg;
//         let mut rooms = Vec::new();

//         // remove session from all rooms
//         for (n, sessions) in &mut self.rooms {
//             if sessions.remove(&id) {
//                 rooms.push(n.to_owned());
//             }
//         }
//         // send message to other users
//         for room in rooms {
//             self.send_message(&room, "Someone disconnected", 0);
//         }

//         if self.rooms.get_mut(&name).is_none() {
//             self.rooms.insert(name.clone(), HashSet::new());
//         }
//         self.send_message(&name, "Someone connected", id);
//         self.rooms.get_mut(&name).unwrap().insert(id);
//     }
// }
