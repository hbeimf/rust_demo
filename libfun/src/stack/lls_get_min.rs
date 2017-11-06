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
        // println!("{:?}", New);
        // self.help.push(New);

        self.help.push(val.clone());
    }

    pub fn pop(&mut self) -> (Option<T>, Option<T>) {    
        (self.top.pop(), self.help.pop())
    }

}

pub fn test() {
    let mut s = Min::<i32>::new();
    println!("{:?}", s);
    s.push(3);
    s.push(4);
    s.push(5);
    
    println!("{:?}", s);
    let (v, min) = s.pop();

    println!("(v, min) = ({:?}, {:?})", v, min);

    println!("{:?}", s);
    

}





