// http://www.cnblogs.com/redclock/p/4995954.html
trait Node {
    fn move_to(&mut self, x: f32, y: f32);
    fn draw(&self);
}


struct EmptyNode {
    x: f32,
    y: f32,
}

impl Node for EmptyNode {
    fn draw(&self) {
        println!("node: x={}, y={}", self.x, self.y)
    }

    fn move_to(&mut self, x: f32, y: f32) {
        self.x = x;
        self.y = y;
        self.draw();
    }
}


impl EmptyNode {  
    fn set_to(&mut self, x: f32, y: f32) {
        self.x = x;
        self.y = y;
    }
}

pub fn test(){
    let mut obj = EmptyNode{ x: 10.0, y: 20.0 };
    obj.draw();
    obj.set_to(11.0, 12.1);
    obj.draw();
    obj.move_to(11.3, 12.2);
    obj.draw();
    
}


// struct Sprite {
//     x: f32,
//     y: f32,
// }

// impl Node for Sprite {
//     fn draw(&self) {
//         println!("sprite: x={}, y={}", self.x, self.y)
//     }

//     fn move_to(&mut self, x: f32, y: f32) {
//         self.x = x;
//         self.y = y;
//     }
// }

