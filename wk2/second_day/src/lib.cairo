#[derive(Copy, Drop)]
struct Book {
    title: felt252,
    author: felt252,
    pub_year: u32,
}

fn types() {
    let x: u8 = 42;
    let y: u8 = x.try_into().unwrap();
    println!("y is : {}", y);
}

fn arrays0() {
    let mut a: Array<u32> = ArrayTrait::new();
    a.append(10);
    a.append(12);
    a.append(1);
    a.append(16);

    let removed_element = a.pop_front().unwrap();
    println!("removed element is: {}", removed_element);
}

fn arrays1() {
    let mut array: Array<u32> = array![];

    array.append(77);

    println!(">> The last element is: {}", array[array.len() - 1]);
}

fn _struct() {
    let mut our_book = Book { title: 'GIDA', author: 'KEVIN', pub_year: 2024, };

    println!(">> author of book of the year is {}", our_book.author);
}


#[derive(Drop)]
enum Message {
    Quit,
    Echo: felt252,
    Move: (u128, u128),
}

trait Processing {
    fn process(self: Message);
}

impl ProcessingImpl of Processing {
    fn process(self: Message) {
        match self {
            Message::Quit => { println!("quitting") },
            Message::Echo(value) => { println!("echoing {}", value) },
            Message::Move((x, y)) => { println!("moving from {} to {}", x, y) },
        }
    }
}
fn enums() {
    let msg: Message = Message::Quit;
    msg.process(); // prints "quitting"
}
fn main() {
    enums();
}
