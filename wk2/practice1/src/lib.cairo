
fn p1(){
    // let num_u8 = 3_u8;
    let num: u8 = 3;
    let num16: u16 = (205).try_into().unwrap();
    let str: ByteArray = "TESTING VARIABLES AND TYPES";
    let _tup: (u8, ByteArray, bool) = (1, "hi", false);

let _x: ByteArray = "1ST";
    let _y: ByteArray = "2ND";
    println!("(demonstrates multi interpolation)...x is: {}, y is: {}", _x,_y );
    
    println!("u8/uint8: {}", num + 8);
    println!("ByteArray: {}", str);
    println!("Converted num: u8 to u16: {}", num16);
}

fn starkling(){
   let number = 1_u8; // don't change this line
    println!("number is {}", number);
    number; // don't rename this variable
    println!("number is {}", number);
}

fn s0(){
    let x: u8 = 7/2;
    println!(">> {}", x);
}

fn main() {
    s0();
}