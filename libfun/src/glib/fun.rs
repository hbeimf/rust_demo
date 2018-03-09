// use std::cmp;
// use std::cmp::Ordering;
// use stack::linked_list_stack::LinkedListStack;

// extern crate itertools;
// use itertools::Itertools;
// pub use structs::*;


// // https://doc.rust-lang.org/std/cmp/trait.Ord.html
// https://doc.rust-lang.org/std/ffi/index.html
// https://rustcc.gitbooks.io/rustprimer/content/type/string.html

use super::super::Itertools;

// pub fn test1() {
// 	let creatures = vec!["banshee", "basilisk", "centaur"];
// 	let list = creatures.iter().join(" $$$");
// 	println!("XX: {}.", list);
// }

pub fn explode<'a>(s: &'a str, subs: &'a str) -> Vec<&'a str> {
	s.split(subs).collect()
}

// pub fn implode_v1(v: Vec<&str>, s: &str) -> String {
// 	let mut result = String::from("");
// 	for i in &v { 
// 		result.push_str(i);
// 		result.push_str(s);
// 	}
// 	result
// }


// fn implode(v: Vec<&str>, s: &str) -> String {
// 	let result = v.iter().fold(String::new(), |mut res, everyone| {
// 		res.push_str(everyone);
// 		res.push_str(s);
// 		res
// 	});
// 	result
// }


// http://blog.csdn.net/guiqulaxi920/article/details/78823541
// https://docs.rs/itertools/0.7.7/itertools/
// 换用新的迭代器，直接使用join 方法
fn implode(v: Vec<&str>, s: &str) -> String {
	let result = v.iter().join(s);
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





