//! `RoomActor` is an actor. It maintains list of connection client session.
//! And manages available rooms. Peers send messages to other peers in same
//! room through `RoomActor`.

use actix::prelude::*;
use std::collections::{HashMap};

use tcps::gen_server;
pub use hub::msg::{Connect, Disconnect, Message};
use rusqlite::types::ToSql;
use rusqlite::{Connection, NO_PARAMS};

#[derive(Debug)]
struct Person {
    id: i32,
    uid: String,
    room_id: String,
}

pub struct RoomActor {
    sessions: HashMap<u32, Recipient<gen_server::Message>>,
    db: rusqlite::Connection,
}

impl Default for RoomActor {
    fn default() -> RoomActor {

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
            db: conn,
        }
    }
}

impl RoomActor {
    fn send_message(&self, message: &Vec<u8>, skip_id: u32) {
        // debug!("send broadcast!!");
        // select where 
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
    }

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

        self.sessions.insert(msg.uid, msg.addr);

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


