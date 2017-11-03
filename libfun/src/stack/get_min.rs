// http://wiki.jikexueyuan.com/project/rust/traits.html

#[derive(Debug)]
struct Min<T> {
    top: Option<Box<Node<T>>>,
    min_top: Option<Box<Node<T>>>,
}

#[derive(Clone,Debug)]
struct Node<T> {
    val: T,
    next: Option<Box<Node<T>>>,
}


impl <T> Node<T> {
    fn new(value: T) -> Node<T> {
        Node { val: value, next: None }
    }
}

impl<T> Min<T> {
    fn new() -> Min<T> {
        Min{ top: None, min_top: None }
    }

    fn push(&mut self, val: T) -> ()  where T:TraitGetVal<i32> + Copy {    
    // fn push(&mut self, val: T) -> ()  {    
             
        println!("val xx: {}", val.get_val());
        
        // set top 
        let mut node = Node::new(val);
        let next = self.top.take();
        node.next = next;
        self.top = Some(Box::new(node));
    
        // println!("val xxss: {}", val.get_val());

        // set min top
        
        let next_top = self.min_top.take();

        // match next_top {
        //     None => {
        //         println!("first push");
        //         let mut node_top = Node::new(val);
        //         node_top.next = self.min_top.take();
        //         self.min_top = Some(Box::new(node_top));   
        //     },
        //     Some(x) => {
        //         println!("second+ push");
        //         let tt = x.val.get_val();
        //         println!("tt:{}", tt);
        //         if val.get_val() <= tt {
        //             println!("here");
        //             let mut node_top = Node::new(val);
        //             node_top.next = self.min_top.take();
        //             // node_top.next = next_top;
        //             self.min_top = Some(Box::new(node_top)); 
                    
        //         } else {
        //             // set top again
        //             println!("there");
                    
        //         }
        //     }, 
        // };

        let mut node_top = Node::new(val);
        node_top.next = next_top;
        self.min_top = Some(Box::new(node_top));   
    }

    fn pop(&mut self) -> (Option<T>, Option<T>) {
        let val = self.top.take();
        let top = match val {
            None => None,
            Some(mut x) => {
                self.top = x.next.take();
                Some(x.val)
            },
        };

        let val1 = self.min_top.take();
        let top1 = match val1 {
            None => None,
            Some(mut x) => {
                self.min_top = x.next.take();
                Some(x.val)
            },
        };
        
        (top, top1)
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

// =================================

pub fn test() {
    let a = TestStruct{ a: 55 };
    let b = TestStruct{ a: 9 };
    // println!("val: {:?}", a);
    
    let mut s = Min::<&TestStruct>::new();
    // assert_eq!(s.pop(), None);

    s.push(&a);
    println!("{:?}", s);
    s.push(&b);
    println!("{:?}", s);

    let (val, min) = s.pop();
    println!("(val, min) = ({:?}, {:?})", val, min);
    // println!("{:?}", min);
    
    println!("{:?}", s);

}





