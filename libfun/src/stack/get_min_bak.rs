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
        // println!("val xxss: {}", val.get_val());
        let next = self.top.take();
        node.next = next;
        self.top = Some(Box::new(node));
    
        println!("val xxss: {}", val.get_val());

        // set min top
        let min_next = self.min_top.take();
        match min_next {
            None => {
                
                // let mut top_node = Node::new(val);
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

impl TraitGetVal<i32> for TestStruct {
    fn get_val(&self) -> i32 {
        self.a
    }
}

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

    // let node = Node::new(&a);
    // let node1 = Node::new(&a);
    
    // println!("node: {}", node.val.get_val());
    // println!("node11: {}", node1.val.get_val());
    

    // println!("val1: {}", a.get_val());
    // println!("val2: {}", &a.get_val());
    
    let mut s = Min::<TestStruct>::new();
    assert_eq!(s.pop(), None);

    s.push(a);
    s.push(b);
    println!("{:?}", s);

    // assert_eq!(s.pop(), Some(&b));
    // assert_eq!(s.pop(), Some(&a));
    // assert_eq!(s.pop(), None);
    // println!("print val: {:?}", a);
}





