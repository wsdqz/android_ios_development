void main () {
Library library = Library();
library.addBook(Book('ponos', 'Fresco', 10000));
library.addBook(Book('ponos2', 'Fresco', 20000));
library.addBook(Book('baobab', 'Zolo', 5000, true));
library.addBook(Book('steam', 'Gaben', 13000));

List<Book> availableBooks = library.getAvailableBooks();
for (Book book in availableBooks) {
  print('${book.title} ${book.author} ${book.price}');
}

print('Total value: ${library.getTotalValue()}');
}

class Book {
  String title;
  String author;
  double price;
  bool isBorrowed = false;
  Book(this.title, this.author, this.price, [this.isBorrowed = false]);
}

class Library {
  List<Book> _books = [];

  void addBook(Book book) {
    _books.add(book);
  }

  List<Book> getAvailableBooks() {
    return _books.where((book) => book.isBorrowed == false).toList();
  }
  double getTotalValue(){
    return _books.fold(0, (sum, book) => sum+book.price);
  }
}

