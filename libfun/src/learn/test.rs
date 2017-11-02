pub fn test() -> String {
    println!("test learn mod!! ===============");
    foo();
    test_foo1();
    "test".to_string()
}


// http://blog.csdn.net/renhuailin/article/details/46471233
// 1. Ownership ===========================================

fn foo() {
    let v = vec![1, 2, 3];  //创建一个vector,并绑定到一个变量
    let v2 = v;   //把它赋给另一个变量。
    // println!("v[0] is: {}", v[0]);   //使用原来的那个绑定变量。
    println!("v[0] is: {}", v2[0]);   
    
}

// 2. References and Borrowing ================================
fn foo1(v1: &Vec<i32>, v2: &Vec<i32>) -> i32 {
    // do stuff with v1 and v2

    // return the answer
    42
}

fn test_foo1() {
    let v1 = vec![1, 2, 3];
    let v2 = vec![1, 2, 3];

    let answer = foo1(&v1, &v2);

    println!("{}", answer);
}

// 3. Lifetime ===================================================











