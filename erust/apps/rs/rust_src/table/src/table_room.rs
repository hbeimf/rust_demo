use actix::prelude::*;
use std::collections::{HashMap};

pub use crate::msg::{Connect, Disconnect, Message, TableMessage};

use rusqlite::types::ToSql;
use rusqlite::{Connection, NO_PARAMS};

#[derive(Debug)]
struct Person {
    id: i32,
    uid: String,
    room_id: String,
}

pub struct RoomActor {
    sessions: HashMap<String, Recipient<TableMessage>>,
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
    fn broadcast_msg(&self, message: &Vec<u8>, _skip_id: u32) {

        // 经验证， 这两连接池是支持断线重连的，
        // mysqlc::test::test();
        // redisc::test();

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

            // let uid = p.uid.parse::<i32>().unwrap();

            if let Some(addr) = self.sessions.get(&p.uid) {
                // debug!("send broadcast");
                let _ = addr.do_send(TableMessage(message.to_vec()));
            }
        }
    }

}

impl Actor for RoomActor {
    type Context = Context<Self>;
}

impl actix::Supervised for RoomActor {}

impl SystemService for RoomActor {
    fn service_started(&mut self, _ctx: &mut Context<Self>) {
        println!("Service started");
    }
}

impl Handler<Connect> for RoomActor {
    type Result = u32;

    fn handle(&mut self, msg: Connect, _: &mut Context<Self>) -> Self::Result {

        self.sessions.insert(msg.uid.to_string(), msg.addr);

        // insert sqlite
        let room_id = 1;
        self.db.execute(
            "INSERT INTO person (uid, room_id)
                      VALUES (?1, ?2)",
            &[&msg.uid as &dyn ToSql, &room_id],
        ).unwrap();

        // send id back
        msg.uid
    }
}

impl Handler<Disconnect> for RoomActor {
    type Result = ();

    fn handle(&mut self, msg: Disconnect, _: &mut Context<Self>) {
        // info!("Disconnect, OUT  OUT  OUT  OUT  Someone disconnected room");

        self.db.execute(
            "delete from person where uid = ?1",
            &[&msg.uid as &dyn ToSql],
        ).unwrap();

    }
}

impl Handler<Message> for RoomActor {
    type Result = ();

    fn handle(&mut self, msg: Message, _: &mut Context<Self>) {
        self.broadcast_msg(&msg.msg, msg.id);
    }
}


