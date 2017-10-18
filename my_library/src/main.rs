// extern crate my_library;

// fn main() {
//     my_library::public_function();
//     my_library::indirect_access();
// }
// ============================

// extern crate my_library;

// fn main() {
//     println!("Hello in English: {}",my_library::english::greetings::hello());
//     println!("Goodbye in English: {}", my_library::english::farewells::goodbye());

//     println!("Hello in Chinese: {}", my_library::chinese::greetings::hello());
//     println!("Goodbye in Chinese: {}", my_library::chinese::farewells::goodbye());
// }

// ==============
extern crate my_library;

fn main() {
    println!("Hello in English: {}", my_library::english::greetings::hello());
    println!("Goodbye in English: {}", my_library::english::farewells::goodbye());

    println!("Hello in Chinese: {}", my_library::chinese::greetings::hello());
    println!("Goodbye in Chinese: {}", my_library::chinese::farewells::goodbye());
}