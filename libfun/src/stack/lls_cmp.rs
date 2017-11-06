// use std::cmp;
use stack::linked_list_stack::LinkedListStack;


#[derive(Debug)]
pub struct Min<T> {
    top: LinkedListStack<T>
}

impl <T> Min<T> {
    pub fn new() -> Min<T> {
        Min{ 
            top: LinkedListStack::<T>::new()
        }
    }

    pub fn push(&mut self, val: T) -> () where T:Clone {   
        // println!("push: {}", val.clone()); 
        self.top.push(val.clone());  
    }

    pub fn pop(&mut self) -> Option<T> {    
        self.top.pop()
    }

}

#[derive(PartialEq, Eq, Debug, Copy, Clone)]
struct Node{
    a: i32,
}

pub fn test() {
    let a = Node{a: 3};
    let b = Node{a: 4};
    let c = Node{a: 5};
    
    let mut s = Min::<&Node>::new();
    println!("{:?}", s);
    s.push(&a);
    s.push(&b);
    s.push(&c);
    
    println!("{:?}", s);
   
    

}





