#[derive(Debug)]
struct MinStack<T> {
    top: Option<Box<StackNode<T>>>,
    min_top: Option<Box<StackNode<T>>>,
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
        MinStack{ top: None, min_top: None }
    }

    fn push(&mut self, val: T) -> ()  where T:TraitGetVal<i32> {    
    // fn push(&mut self, val: T) -> ()  {    
             
        println!("val xx: {}", val.get_val());
        
        // set top 
        let mut node = StackNode::new(val);
        // println!("val xxss: {}", val.get_val());
        let next = self.top.take();
        node.next = next;
        self.top = Some(Box::new(node));
    
        // println!("val xxss: {}", val.get_val());

        // set min top
        let min_next = self.min_top.take();
        match min_next {
            None => {
                
                // let mut top_node = StackNode::new(val);
                // let top_next = self.min_top.take();
                // top_node.next = top_next;
                // self.min_top = Some(Box::new(top_node));
            },
            // Some(mut x) => {
            Some(x) => {
                println!("val: {}", x.val.get_val());
            },
        };
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
trait TraitGetVal<T> {
    fn get_val(&self) -> T;
}

#[derive(PartialEq, Eq, Debug, Copy, Clone)]
struct TestStruct {
    a: i32,
}

// impl TraitGetVal<i32> for TestStruct {
//     fn get_val(&self) -> i32 {
//         self.a
//     }
// }

impl <'a> TraitGetVal<i32> for &'a TestStruct {
    fn get_val(&self) -> i32 {
        self.a
    }
}

// impl <'a> Copy for &'a TestStruct { 

// }


// =================================

pub fn test() {
    let a = TestStruct{ a: 5 };
    let b = TestStruct{ a: 9 };
    println!("val: {:?}", a);
    // println!("val1: {}", a.get_val());
    // println!("val2: {}", &a.get_val());
    
    let mut s = MinStack::<&TestStruct>::new();
    assert_eq!(s.pop(), None);

    s.push(&a);
    s.push(&b);
    println!("{:?}", s);

    assert_eq!(s.pop(), Some(&b));
    assert_eq!(s.pop(), Some(&a));
    assert_eq!(s.pop(), None);
    println!("print val: {:?}", a);
}





