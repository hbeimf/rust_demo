// https://doc.rust-lang.org/std/string/struct.String.html
// https://doc.rust-lang.org/std/primitive.str.html

use std::string::String;


pub fn test() -> String {
    println!("test string mod!! ===============");
    let from_string = "hello world!";
    let find = "hello";
    let to = "hi";
    let new_str = replace(from_string, find, to);
    println!("new str: {}", new_str);



    "test".to_string()
}

pub fn replace(from_string: &str, find: &str, to: &str) -> String {
    // let s = String::from(from_string);
    from_string.replace(find, to)
}



