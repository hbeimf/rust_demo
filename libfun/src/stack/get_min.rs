#[derive(Debug)]
struct MinStack<T> {
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

impl<T> MinStack<T> {
    fn new() -> MinStack<T> {
        MinStack{ top: None }
    }

    fn push(&mut self, val: T) -> ()  where T:TGetVal<i32> {         
        println!("val: {}", val.get_val());
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


// =============================
// #[derive(Debug)]
trait TGetVal<T> {
    fn get_val(&self) -> T;
}

#[derive(PartialEq,Eq,Debug)]
struct TestStruct {
    a: i32,
}

impl TGetVal<i32> for TestStruct {
    fn get_val(&self) -> i32 {
        self.a
    }
}

// =================================

pub fn test() {
    let a = TestStruct{ a: 5 };
    let b = TestStruct{ a: 9 };
    println!("val: {:?}", a);

    let mut s = MinStack::<TestStruct>::new();
    assert_eq!(s.pop(), None);

    s.push(a);
    s.push(b);
    println!("{:?}", s);

    // assert_eq!(s.pop(), Some(b));
    // assert_eq!(s.pop(), Some(a));
    // assert_eq!(s.pop(), None);
}





