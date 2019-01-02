//! `RoomActor` is an actor. It maintains list of connection client session.
//! And manages available rooms. Peers send messages to other peers in same
//! room through `RoomActor`.

use actix::prelude::*;
// use rand::{self, Rng};
// use rand::{self, Rng, ThreadRng};

// use std::cell::RefCell;
// use std::collections::{HashMap, HashSet};
use std::collections::{HashMap};

use tcps::gen_server;
pub use hub::msg::{Connect, Disconnect, Message};

// use actix::prelude::Request;

use rusqlite::types::ToSql;
use rusqlite::{Connection, NO_PARAMS};
// use time::Timespec;

#[derive(Debug)]
struct Person {
    id: i32,
    uid: String,
    room_id: String,
}

// pub fn get_uid() -> u32 {
//     let rng = RefCell::new(rand::thread_rng());
//     let id = rng.borrow_mut().gen::<u32>();
//     id
// }

/// `RoomActor` manages chat rooms and responsible for coordinating chat
/// session. implementation is super primitive
pub struct RoomActor {
    sessions: HashMap<u32, Recipient<gen_server::Message>>,
    // rooms: HashMap<String, HashSet<u32>>,
    // rng: RefCell<ThreadRng>,
    db: rusqlite::Connection,
}

impl Default for RoomActor {
    fn default() -> RoomActor {
        // default room
        // let mut rooms = HashMap::new();
        // rooms.insert("Main".to_owned(), HashSet::new());

        let conn = Connection::open_in_memory().unwrap();

        conn.execute(
            "CREATE TABLE person (
                      id              INTEGER PRIMARY KEY,
                      uid             TEXT NOT NULL,
                      room_id         TEXT NOT NULL
                      )",
            NO_PARAMS,
        ).unwrap();

        RoomActor {
            sessions: HashMap::new(),
            // rooms: rooms,
            // rng: RefCell::new(rand::thread_rng()),
            db: conn,
        }
    }
}

impl RoomActor {
    fn send_message(&self, message: &Vec<u8>, skip_id: u32) {
        debug!("send broadcast!!");

        // select where 
        // println!("where id = 2");

        let mut stmt = self.db
            .prepare("SELECT id, uid, room_id FROM person where room_id = ?1")
            .unwrap();
        let person_iter = stmt
            .query_map(&[1], |row| Person { // where
                id: row.get(0),
                uid: row.get(1),
                room_id: row.get(2),
            }).unwrap();

        for person in person_iter {
            let p = person.unwrap();

            println!("Found person {:?}", p);

            let uid = p.uid.parse::<i32>().unwrap();

            if let Some(addr) = self.sessions.get(&(uid as u32)) {
                debug!("send broadcast");
                let _ = addr.do_send(gen_server::Message(message.to_vec()));
            }
        }
        
        //
        // if let Some(addr) = self.sessions.get(id) {
        //     debug!("send broadcast");
        //     let _ = addr.do_send(gen_server::Message(message.to_vec()));
        // }
      
    }

    // fn send_message(&self, room: &str, message: &Vec<u8>, skip_id: u32) {
    //     debug!("send broadcast!!");
    //     if let Some(sessions) = self.rooms.get(room) {
    //         for id in sessions {
    //             if *id != skip_id {
    //                 if let Some(addr) = self.sessions.get(id) {
    //                     debug!("send broadcast");
    //                     let _ = addr.do_send(gen_server::Message(message.to_vec()));
    //                 }
    //             }
    //         }
    //     }
    // }

    // fn send_message_by_room_id(&self, message: &Vec<u8>, room_id: u32) {
    //     debug!("broadcast send_message_by_room_id!!");
    // }
       
}

/// Make actor from `RoomActor`
impl Actor for RoomActor {
    /// We are going to use simple Context, we just need ability to communicate
    /// with other actors.
    type Context = Context<Self>;
}

impl actix::Supervised for RoomActor {}

impl SystemService for RoomActor {
    fn service_started(&mut self, _ctx: &mut Context<Self>) {
        println!("Service started");
    }
}

/// Handler for Connect message.
///
/// Register new session and assign unique id to this session
impl Handler<Connect> for RoomActor {
    type Result = u32;

    fn handle(&mut self, msg: Connect, _: &mut Context<Self>) -> Self::Result {
        info!("Connect,IN IN IN IN IN IN Someone joined room");

        // notify all users in same room
        // self.send_message(&"Main".to_owned(), "Someone joined", 0);

        // register session with random id
        // let id = self.rng.borrow_mut().gen::<u32>();

        self.sessions.insert(msg.uid, msg.addr);

        // auto join session to Main room
        // self.rooms.get_mut(&"Main".to_owned()).unwrap().insert(msg.uid);

        // insert sqlite
        let room_id = 1;
        self.db.execute(
            "INSERT INTO person (uid, room_id)
                      VALUES (?1, ?2)",
            &[&msg.uid as &ToSql, &room_id],
        ).unwrap();

        // send id back
        msg.uid
    }
}

/// Handler for Disconnect message.
impl Handler<Disconnect> for RoomActor {
    type Result = ();

    fn handle(&mut self, msg: Disconnect, _: &mut Context<Self>) {
        info!("Disconnect, OUT  OUT  OUT  OUT  Someone disconnected room");

        // let mut rooms: Vec<String> = Vec::new();

        // remove address
        // if self.sessions.remove(&msg.uid).is_some() {
        //     // remove session from all rooms
        //     for (name, sessions) in &mut self.rooms {
        //         if sessions.remove(&msg.uid) {
        //             rooms.push(name.to_owned());
        //         }
        //     }
        // }

        // // send message to other users
        // for room in rooms {
        //     self.send_message(&room, "Someone disconnected", 0);
        // }

        self.db.execute(
            "delete from person where uid = ?1",
            &[&msg.uid as &ToSql],
        ).unwrap();

    }
}

/// Handler for Message message.
impl Handler<Message> for RoomActor {
    type Result = ();

    fn handle(&mut self, msg: Message, _: &mut Context<Self>) {
        // self.send_message(&msg.room, msg.msg.as_str(), msg.id);
        debug!("广播消息 room:{:?}, msg:{:?}, id:{:?}", &msg.room, &msg.msg, msg.id);
        self.send_message(&msg.msg, msg.id);

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


// pub fn sqlite() {
//     let conn = Connection::open_in_memory().unwrap();

//     conn.execute(
//         "CREATE TABLE person (
//                   id              INTEGER PRIMARY KEY,
//                   name            TEXT NOT NULL,
//                   time_created    TEXT NOT NULL,
//                   data            BLOB
//                   )",
//         NO_PARAMS,
//     )
//     .unwrap();
//     let me = Person {
//         id: 0,
//         name: "Steven".to_string(),
//         time_created: time::get_time(),
//         data: None,
//     };
    
//     // insert 
//     conn.execute(
//         "INSERT INTO person (name, time_created, data)
//                   VALUES (?1, ?2, ?3)",
//         &[&me.name as &ToSql, &me.time_created, &me.data],
//     )
//     .unwrap();
//     conn.execute(
//         "INSERT INTO person (name, time_created, data)
//                   VALUES (?1, ?2, ?3)",
//         &[&me.name as &ToSql, &me.time_created, &me.data],
//     )
//     .unwrap();
//     conn.execute(
//         "INSERT INTO person (name, time_created, data)
//                   VALUES (?1, ?2, ?3)",
//         &[&me.name as &ToSql, &me.time_created, &me.data],
//     )
//     .unwrap();

//     // select 
//     let mut stmt = conn
//         .prepare("SELECT id, name, time_created, data FROM person")
//         .unwrap();
//     let person_iter = stmt
//         .query_map(NO_PARAMS, |row| Person {
//             id: row.get(0),
//             name: row.get(1),
//             time_created: row.get(2),
//             data: row.get(3),
//         })
//         .unwrap();

//     for person in person_iter {
//         println!("Found person {:?}", person.unwrap());
//     }


//     // update where
//     let new_name = "testUpdateName".to_string();
//     let id = 2;
//     conn.execute(
//         "UPDATE person SET name = ?1 where id = ?2",
//         &[&new_name as &ToSql, &id],
//     )
//     .unwrap();

//     // select where 
//     println!("where id = 2");

//     let mut stmt = conn
//         .prepare("SELECT id, name, time_created, data FROM person where id = ?1")
//         .unwrap();
//     let person_iter = stmt
//         .query_map(&[2], |row| Person { // where
//             id: row.get(0),
//             name: row.get(1),
//             time_created: row.get(2),
//             data: row.get(3),
//         })
//         .unwrap();

//     for person in person_iter {
//         println!("Found person {:?}", person.unwrap());
//     }
// }
