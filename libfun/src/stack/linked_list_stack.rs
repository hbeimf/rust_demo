// https://doc.rust-lang.org/std/collections/struct.LinkedList.html

use std::collections::LinkedList;


#[derive(Debug)]
pub struct LinkedListStack<T> {
    top: LinkedList<T>,
}

impl <T> LinkedListStack<T> {

    pub fn new() -> LinkedListStack<T> {
        LinkedListStack{ top: LinkedList::<T>::new()}
    }

    pub fn push(&mut self, val: T) {    
        self.top.push_front(val);
    }

    pub fn pop(&mut self) -> Option<T> {    
        self.top.pop_front()
    }
    
}

pub fn test() {
    let mut s = LinkedListStack::<i32>::new();
    s.push(3);
    s.push(4);
    s.push(5);
    
    println!("{:?}", s);
    let r = s.pop();
    println!("{:?}", r);
    println!("{:?}", s);


}

