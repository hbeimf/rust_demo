// #[macro_use]
extern crate actix;
extern crate actix_web;

extern crate rusqlite;
extern crate time;

pub mod msg;
pub mod table_room;

use crate::table_room::{RoomActor};
use actix::prelude::*;

#[macro_use]
extern crate log;

pub fn start_room_actor() {
	warn!("start room actor");
	let _act = System::current().registry().get::<RoomActor>();
}
