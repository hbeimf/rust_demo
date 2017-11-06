// use std::cmp;
use stack::linked_list_stack::LinkedListStack;


#[derive(Debug)]
pub struct Min<T> {
    top: LinkedListStack<T>,
    help: LinkedListStack<T>,
}

impl <T> Min<T> {
    pub fn new() -> Min<T> {
        Min{ 
            top: LinkedListStack::<T>::new(), 
            help: LinkedListStack::<T>::new() 
        }
    }

    pub fn push(&mut self, val: T) -> () where T:Clone {   
        // println!("push: {}", val.clone()); 
        self.top.push(val.clone());

        // let New = match self.help.pop() {
        //     None => {
        //         val.clone()
        //     },
        //     Some(x) => {
        //         // if x > val.clone() {
        //         //     val.clone()
        //         // } else {
        //         //     x
        //         // }
        //         x
        //     } 
        // };
        // let yes = cmp::min(val.clone(), New);


        // println!("{}", yes);
        // self.help.push(New);

        self.help.push(val.clone());
    }

    pub fn pop(&mut self) -> (Option<T>, Option<T>) {    
        (self.top.pop(), self.help.pop())
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
    let (v, min) = s.pop();

    println!("(v, min) = ({:?}, {:?})", v, min);

    println!("{:?}", s);
    

}





