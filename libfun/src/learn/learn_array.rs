
pub fn test() {
    let a = [1,2,3,4,5];  
    let b = [0;20];  
    println!("{}",a.len());  
    println!("{}",b.len());  
    println!("{:?}",a);  
    println!("{:?}",b);  
    for x in a.iter(){  
        println!("{}",x);  
    }     
    for x in b.iter(){  
        println!("{}",x)  
    }  
}