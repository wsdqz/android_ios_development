void main() {
  ShoppingCart cart = ShoppingCart();
  
  cart.addItem(Audiobook('1', 'How to be a billioner', 2000, 32, 'Serega Pirat'));
  cart.addItem(EBook('1', 'Peppa pig', 500, 1.5, "James Piggster"));
  cart.addItem(Audiobook('2', '7 days to die', 7000, 97, 'Bobik Mirny'));
  cart.addItem(EBook('2', 'OOP guide', 1200, 3.72, "Super Prepod"));

  cart.printReceipt();

  print('Items cheaper than 6767:');
  List<MediaItem> items = cart.filterByMaxPrice(6767);
  for (MediaItem item in items) {
    print(item.getDetails());
  }
}

abstract class MediaItem {
  String id;
  String title;
  double price;
  MediaItem(this.id, this.title, this.price);

  String getDetails();
}

mixin Downloadable {
  void download(String title) {
    print('Downloading "$title"...\n');
  }
}

class Audiobook extends MediaItem with Downloadable {
  double durationHours;
  String narrator;

  Audiobook(String id, String title, double price, this.durationHours, this.narrator)
    : super(id, title, price);

  String getDetails() {
    return 'Audiobook [$id]: "$title", $narrator, price: $price, duration: ${durationHours}h';
  }
}

class EBook extends MediaItem with Downloadable {
  double fileSizeMB;
  String author;

  EBook(String id, String title, double price, this.fileSizeMB, this.author)
    : super(id, title, price);

  String getDetails() {
    return 'EBook [$id]: "$title", $author, price: $price, size: ${fileSizeMB}mb';
   }
  }

  class ShoppingCart {
    List<MediaItem> _items = [];
    
    void addItem(MediaItem item){
      _items.add(item);
    }

    double calculateTotalWithTax({double taxRate = 0.12}){
      double total = _items.fold (0, (sum, item) => sum + item.price);
      double tax = total * taxRate;
      return total + tax;
    }

    List<MediaItem> filterByMaxPrice(double maxPrice){
      return _items.where((item) => item.price <= maxPrice).toList();
    }

    void printReceipt(){
      print('Your receipt:');
      for (MediaItem item in _items) {
        print(item.getDetails());
        if (item is Downloadable) {
          (item as Downloadable).download(item.title);
        }
      }
    }
}