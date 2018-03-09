// use std::cmp;
// use std::cmp::Ordering;
// use stack::linked_list_stack::LinkedListStack;

// // https://doc.rust-lang.org/std/cmp/trait.Ord.html
// https://doc.rust-lang.org/std/ffi/index.html
// https://rustcc.gitbooks.io/rustprimer/content/type/string.html

pub fn explode(s: &str) {
	let mut y:String = s.to_string();
	println!("{}", y);
	y.push_str(", world");
	println!("{}", y);
}



pub fn test() {

    println!("funs");

    explode("hello world");
}





