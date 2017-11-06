// use std::cmp;
use stack::linked_list_stack::LinkedListStack;


#[derive(Debug)]
pub struct Min {
    top: LinkedListStack<i32>,
    help: LinkedListStack<i32>,
}

impl Min {
    pub fn new() -> Min {
        Min{ 
            top: LinkedListStack::<i32>::new(), 
            help: LinkedListStack::<i32>::new() 
        }
    }

    pub fn push(&mut self, val: i32) {   
        // println!("push: {}", val.clone()); 
        self.top.push(val.clone());

        let n = match self.help.pop() {
            None => {
                val.clone()
            },
            Some(x) => {
                self.help.push(x);

                if x >= val.clone() {
                    val.clone()
                } else {
                    x
                }
            }
        };
        println!("{}", n);

        self.help.push(n);
    }

    pub fn pop(&mut self) -> (Option<i32>, Option<i32>) {    
        (self.top.pop(), self.help.pop())
    }

}

// #[derive(PartialEq, Eq, Debug, Copy, Clone)]
// struct Node{
//     a: i32,
// }

pub fn test() {
    let a = 3;
    let b = 4;
    let c = 5;
    let d = 2;
    
    let mut s = Min::new();
    println!("{:?}", s);
    s.push(a);
    s.push(b);
    s.push(c);
    s.push(d);
    
    println!("{:?}", s);
    let (v, min) = s.pop();
    println!("(v, min) = ({:?}, {:?})", v, min);
    println!("{:?}", s);

    let (v, min) = s.pop();
    println!("(v, min) = ({:?}, {:?})", v, min);
    println!("{:?}", s);

    let (v, min) = s.pop();
    println!("(v, min) = ({:?}, {:?})", v, min);
    println!("{:?}", s);
    

}





