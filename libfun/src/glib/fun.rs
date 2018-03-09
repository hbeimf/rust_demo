// use std::cmp;
// use std::cmp::Ordering;
// use stack::linked_list_stack::LinkedListStack;

// // https://doc.rust-lang.org/std/cmp/trait.Ord.html
// https://doc.rust-lang.org/std/ffi/index.html
// https://rustcc.gitbooks.io/rustprimer/content/type/string.html

pub fn explode<'a>(s: &'a str, subs: &'a str) -> Vec<&'a str> {
	s.split(subs).collect()
}

pub fn implode_v1(v: Vec<&str>, s: &str) -> String {
	let mut result = String::from("");
	for i in &v { 
		result.push_str(i);
		result.push_str(s);
	}
	result
}


fn implode(v: Vec<&str>, s: &str) -> String {
	let result = v.iter().fold(String::new(), |mut res, everyone| {
		res.push_str(everyone);
		res.push_str(s);
		res
	});
	result
}

pub fn test() {
	let demo_str = "hello$world $this $space XX$explode"; 
	println!("demostr: {:?}", demo_str);
	let r = explode(demo_str, "$");
	println!("explode: {:?}", r);
	let s = implode(r, "$");
	println!("implode: {:?}", s);	
}





