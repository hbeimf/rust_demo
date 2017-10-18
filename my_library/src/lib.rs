// pub fn public_function() {
//     println!(" my library's `public_function()` called");
// }

// fn private_function() {
//     println!(" my library's `private_function()` called");
// }

// pub fn indirect_access() {
//     print!("my library's `indirect_access()` called ");
//     private_function();
// }

// ==================================
// pub mod english {
//      pub  mod greetings {
//           pub fn hello() -> String {
//             "Hello!".to_string()
//           }
//      }

//      pub  mod farewells {
//         pub fn goodbye() -> String {
//             "Goodbye.".to_string()
//         }
//     }
// }

// pub mod chinese {
//    pub mod greetings {
//         pub fn hello() -> String {
//            "你好!".to_string()
//         }
//     }

//    pub mod farewells {
//        pub fn goodbye() -> String {
//             "再见.".to_string()
//         }
//     }
// }
// ======================================================

pub mod english;
pub mod chinese;