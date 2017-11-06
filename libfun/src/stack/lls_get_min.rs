use stack::linked_list_stack::LinkedListStack;

#[derive(Debug)]
pub struct Min<T> {
    top: LinkedListStack<T>,
    help: LinkedListStack<T>,
}

impl <T> Min<T> {
    fn new() -> Min<T> {
        Min{ 
            top: LinkedListStack::<T>::new(), 
            help: LinkedListStack::<T>::new() 
        }
    }

    fn push(&mut self, val: T) -> () where T:Clone {    
        self.top.push(val.clone());
        self.help.push(val.clone());
    }

    fn pop(&mut self) -> (Option<T>, Option<T>) {    
        (self.top.pop(), self.help.pop())
    }

}

pub fn test() {
    let mut s = Min::<i32>::new();
    println!("{:?}", s);
    s.push(3);
    println!("{:?}", s);
    s.pop();


}





