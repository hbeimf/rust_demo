// https://doc.rust-lang.org/std/string/struct.String.html

use std::string::String;


pub fn test() -> String {
    println!("test string mod!! ===============");
    let new_str = replace("hello world!", "hello", "hi");
    println!("new str: {}", new_str);



    "test".to_string()
}

pub fn replace(from_string: &str, find: &str, to: &str) -> String {
    let s = String::from(from_string);
    s.replace(find, to)
}



