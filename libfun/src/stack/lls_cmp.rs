use std::cmp;
use std::cmp::Ordering;
use stack::linked_list_stack::LinkedListStack;

// https://doc.rust-lang.org/std/cmp/trait.Ord.html

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

    pub fn push(&mut self, val: T) -> () where T:Clone + Ord {   
        let n = match self.top.pop() {
            None => {
                val.clone()        
            },
            Some(x) => {
                self.top.push(x.clone());
                cmp::min(val, x)
            } 
        };

        self.top.push(n);  
    }

    pub fn pop(&mut self) -> Option<T> {    
        self.top.pop()
    }

}

#[derive(PartialEq, PartialOrd, Eq, Debug, Copy, Clone)]
struct Node{
    val: i32,
}

impl Ord for Node {
    fn cmp(&self, other: &Node) -> Ordering {
        self.val.cmp(&other.val)
    }
}

pub fn test() {
    let a = Node{val: 3};
    let b = Node{val: 4};
    let c = Node{val: 5};
    
    let mut s = Min::<Node>::new();
    println!("{:?}", s);
    s.push(a);
    s.push(b);
    s.push(c);
    
    println!("{:?}", s);
   
    

}





