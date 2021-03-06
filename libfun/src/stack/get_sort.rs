// http://wiki.jikexueyuan.com/project/rust-primer/data-structure/stack.html

#[derive(Debug)]
struct Stack<T> {
    top: Option<Box<StackNode<T>>>,
}

#[derive(Clone,Debug)]
struct StackNode<T> {
    val: T,
    next: Option<Box<StackNode<T>>>,
}

impl <T> StackNode<T> {
    fn new(val: T) -> StackNode<T> {
        StackNode { val: val, next: None }
    }
}

impl<T> Stack<T> {
    fn new() -> Stack<T> {
        Stack{ top: None }
    }

    fn push(&mut self, val: T) {
        let mut node = StackNode::new(val);
        let next = self.top.take();
        node.next = next;
        self.top = Some(Box::new(node));
    }

    fn pop(&mut self) -> Option<T> {
        let val = self.top.take();
        match val {
            None => None,
            Some(mut x) => {
                self.top = x.next.take();
                Some(x.val)
            },
        }
    }
}

pub fn test() {
    #[derive(PartialEq,Eq,Debug)]
    struct TestStruct {
        a: i32,
    }

    let a = TestStruct{ a: 5 };
    let b = TestStruct{ a: 9 };
    let c = TestStruct{ a: 1 };
    

    let mut stack = Stack::<&TestStruct>::new();
    let mut help_stack = Stack::<&TestStruct>::new();
    
    // assert_eq!(s.pop(), None);  
    println!("help:{:?}", help_stack);

    stack.push(&a);
    stack.push(&b);
    stack.push(&c);
    help_stack.push(&a);

    println!("{:?}", stack);

    // sort 
    stack.pop();
    println!("{:?}", stack);
    stack.pop();
    println!("{:?}", stack);
    stack.pop();
    println!("{:?}", stack);
    

    // assert_eq!(s.pop(), Some(&b));
    // assert_eq!(s.pop(), Some(&a));
    // assert_eq!(s.pop(), None);
    // sort();
}

// fn sort() {

// }


