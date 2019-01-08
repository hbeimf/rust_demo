use pool;
use table_post;

pub fn test() {
	let mysql = pool::MYSQL_INSTANCE.get(); 
    
	match mysql.pool.get() {
	            Ok(conn) => {
	            		let delete_instance = table_post::Delete::new();
	            		let _d_res = delete_instance.delete(&conn);

	            		let update_instance = table_post::Update::new();
	            		let _u_res = update_instance.update(&conn);

	            		let insert_instance = table_post::Insert::new("titletest 111".to_string(), "body test 111".to_string());
	            		let _res = insert_instance.insert(&conn);


	            		let select_instance = table_post::Select::new();
	            		let _res = select_instance.select(&conn);

	            },
	            _ => {
	            		println!("something else");
	            }
	}	
}

