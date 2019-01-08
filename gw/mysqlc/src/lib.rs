
#[macro_use]
extern crate diesel;
extern crate r2d2;
extern crate r2d2_diesel;

extern crate sys_config;

#[macro_use]
extern crate singleton;

pub mod test;
pub mod pool;
pub mod schema;
pub mod table_post;

extern crate easy_logging;