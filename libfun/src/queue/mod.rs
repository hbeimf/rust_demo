#[derive(Debug)]
struct Queue<T> {
    qdata: Vec<T>,
}

impl <T> Queue<T> {
    // fn new() -> Self {
    fn new() -> Queue<T> {   
        Queue{qdata: Vec::new()}
    }

    fn push(&mut self, item:T) {
        self.qdata.push(item);
    }

    fn pop(&mut self) -> T{
        self.qdata.remove(0)
    }
}

pub fn test() {
    test_num();
    test_str();
}

fn test_num() {
    let mut q = Queue::new();
    q.push(1);
    q.push(2);
    println!("{:?}", q);
    q.pop();
    println!("{:?}", q);
    q.pop();
    println!("{:?}", q);
    
    // q.pop();
    // q.pop();
    
}

fn test_str() {
    let mut q = Queue::new();
    q.push("hello");
    q.push("world");
    println!("{:?}", q); 
}
