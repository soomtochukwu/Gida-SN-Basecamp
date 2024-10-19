// possible functions to implement

// WRITE FUNCTIONS
// add books
// remove books
// order book
// borrow book

// READ FUNCTIONS
// get book
// get total number of books
///
// get customer (ppl who ordered book(s))
// get reader(s) (ppl who borrowed book(s))
// sort by author
// sort by publisher
use core::starknet::ContractAddress;

#[derive(Copy, Drop, Serde, starknet::Store)]
struct Book {
    id: felt252,
    title: felt252,
    author: felt252,
    ISBN: felt252,
    publication_date: felt252,
    edition: felt252,
    price: u256,
    page_count: felt252,
    language: felt252,
    genre: felt252,
    removed: bool
}


#[starknet::interface]
pub trait IERC20<TContractState> {
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
}

#[starknet::interface]
pub trait IGidaBookStore<TContractState> {
    //
    // write functions
    fn add_book(
        ref self: TContractState,
        title: felt252,
        author: felt252,
        ISBN: felt252,
        publication_date: felt252,
        edition: felt252,
        price: u256,
        page_count: felt252,
        language: felt252,
        genre: felt252,
    );
    fn remove_book(ref self: TContractState, book_id: felt252);
    fn borrow_book(ref self: TContractState, book_id: felt252);
    fn order_book(ref self: TContractState, book_id: felt252);

    //
    // // read functions
    fn get_total_number_of_books(self: @TContractState) -> felt252;
    fn get_book(self: @TContractState, book_id: felt252) -> Book;
}

#[starknet::contract]
pub mod Gida_Book_Store {
    use starknet::event::EventEmitter;
    use super::{IERC20Dispatcher, IERC20DispatcherTrait};
    use core::starknet::{
        ContractAddress, get_caller_address,
        storage::{Map, StorageMapReadAccess, StorageMapWriteAccess}
    };


    use super::{Book};


    #[storage]
    struct Storage {
        Books: Map<felt252, Book>,
        borrowed_books: Map<ContractAddress, felt252>, // mapping(address => book_id)  
        orders: Map<ContractAddress, felt252>, // mapping(address => book_id)
        book_count: felt252,
        admin: ContractAddress,
    }


    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Book_added: Book_added,
        Book_removed: Book_removed,
        Order: Order,
        Borrow: Borrow
    }

    #[derive(Drop, starknet::Event)]
    struct Book_added {
        book_id: felt252,
        title: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct Book_removed {
        book_id: felt252,
        title: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct Order {
        buyer: ContractAddress,
        title: felt252,
        book_id: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct Borrow {
        buyer: ContractAddress,
        title: felt252,
        book_id: felt252,
    }


    #[constructor]
    fn constructor(ref self: ContractState) {
        self.book_count.write(0); // Initialize the book count to 0.
        self.admin.write(get_caller_address()); // Set admin as the contract caller.
    }

    #[abi(embed_v0)]
    impl Gida_Book_Store_Impl of super::IGidaBookStore<ContractState> {
        fn add_book(
            ref self: ContractState,
            title: felt252,
            author: felt252,
            ISBN: felt252,
            publication_date: felt252,
            edition: felt252,
            price: u256,
            page_count: felt252,
            language: felt252,
            genre: felt252,
        ) {
            let book = Book {
                id: self.book_count.read(),
                title: title,
                author: author,
                ISBN: ISBN,
                publication_date: publication_date,
                edition: edition,
                price: price,
                page_count: page_count,
                language: language,
                genre: genre,
                removed: false
            };
            self.Books.write(self.book_count.read(), book);
            self.book_count.write(self.book_count.read() + 1);
            self.emit(Book_added { book_id: book.id, title })
        }

        fn remove_book(ref self: ContractState, book_id: felt252) {
            let mut book: Book = self.Books.read(book_id);
            book.removed = true;
            self.Books.write(book_id, book);
            self.emit(Book_removed { book_id: book.id, title: book.title })
        }

        fn borrow_book(ref self: ContractState, book_id: felt252) {
            let caller_address = get_caller_address();
            let book: Book = self.Books.read(book_id);
            self.borrowed_books.write(caller_address, book_id);
            self.emit(Borrow { buyer: get_caller_address(), title: book.title, book_id })
        }

        fn order_book(ref self: ContractState, book_id: felt252) {
            let erc20_dispatcher = IERC20Dispatcher {
                contract_address: 0x049d36570d4e46f48e99674bd3fcc84644ddd6b96f7c741b1562b82f9e004dc7
                    .try_into()
                    .unwrap()
            };
            let book: Book = self.Books.read(book_id);

            erc20_dispatcher
                .transfer(
                    0x032CeEeC540FDAf1FB15fF9e2EEcD93E3e5b8DD12c7b5ED998aBc366F4FfdF8C
                        .try_into()
                        .unwrap(),
                    self.Books.read(book_id).price
                );
            self.orders.write(get_caller_address(), book_id);

            self.emit(Borrow { buyer: get_caller_address(), title: book.title, book_id })
        }

        //

        fn get_total_number_of_books(self: @ContractState) -> felt252 {
            self.book_count.read()
        }

        fn get_book(self: @ContractState, book_id: felt252) -> Book {
            self.Books.read(book_id)
        }
    }
}
