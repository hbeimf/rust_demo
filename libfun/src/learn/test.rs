use learn;
use stack;

pub fn test() -> String {
    println!("test learn mod!! ===============");
    learn::learn_array::test();
    stack::test();
    learn::learn_trait::test();
    "test".to_string()
}

