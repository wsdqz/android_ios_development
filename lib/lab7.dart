import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class Product {
  final String title;
  final String description;
  final String image;
  final String price;
  final String category;

  const Product({
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.category,
  });
}

const products = [
  Product(
    title: 'Apple AirPods Pro 3',
    description: 'The world’s best in-ear Active Noise Cancellation, with heart rate sensing during workouts',
    image: 'https://prod-cdn.prod.asbis.io/s3size/el:t/f:webp/rt:fill/plain/s3://cms/product/77/b2/77b2b078ccedce46f18e0514e7476d28/250910160020664746.webp',
    price: '\$129',
    category: 'Audio',
  ),
  Product(
    title: 'Apple Watch Series 11',
    description: 'A powerful way to watch your health.',
    image: 'https://www.apple.com/assets-www/en_WW/watch/product_tile/large/s11_01ae61a6b_2x.png',
    price: '\$149',
    category: 'Wearables',
  ),
  Product(
    title: 'Apple Magic Keyboard',
    description: 'Sleek and responsive wireless typing, with Touch ID for secure authentication and seamless Apple ecosystem integration.',
    image: 'https://resources.cdn-kaspi.kz/img/cnt/rc/i/p16/p8b/148934.jpg',
    price: '\$99',
    category: 'Computers',
  ),
  Product(
    title: 'Apple Backpack',
    description: 'Comfyable Puffer Tote for 15" and 16" MacBook.',
    image: 'https://store.storeimages.cdn-apple.com/1/as-images.apple.com/is/HSF62?wid=890&hei=890&fmt=jpeg&qlt=90&.v=ZTYxU2dKZllYOFlTakplRGNjanNNb3ExblZJSGFXSFVPMUE2c2RxMy8rSXFuRWY4U0FLcTd2UGF5TzUySHNzSTlWdXM2UTZKTUdOOVB5alVxTTZSbVE',
    price: '\$89',
    category: 'Accessories',
  ),
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
        ),
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;
  final List<Product> _favorites = [];

  void _toggleFavorite(Product p) {
    setState(() {
      if (_favorites.contains(p)) {
        _favorites.remove(p);
      } else {
        _favorites.add(p);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      FeedTab(favorites: _favorites, onFavorite: _toggleFavorite),
      FavoritesTab(favorites: _favorites),
      const ProfileTab(),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: tabs[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Feed'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class FeedTab extends StatelessWidget {
  final List<Product> favorites;
  final Function(Product) onFavorite;

  const FeedTab({super.key, required this.favorites, required this.onFavorite});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: products.map((p) {
        return ListTile(
          leading: Image.network(p.image, width: 60, fit: BoxFit.cover),
          title: Text(p.title),
          subtitle: Text(p.price),
          trailing: IconButton(
            icon: Icon(
              favorites.contains(p) ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: () => onFavorite(p),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailScreen(product: p)),
            );
          },
        );
      }).toList(),
    );
  }
}

class FavoritesTab extends StatelessWidget {
  final List<Product> favorites;

  const FavoritesTab({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const Center(child: Text('No favorites yet'));
    }
    return ListView(
      children: favorites.map((p) {
        return ListTile(
          leading: Image.network(p.image, width: 60, fit: BoxFit.cover),
          title: Text(p.title),
          subtitle: Text(p.price),
        );
      }).toList(),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
          SizedBox(height: 16),
          Text('Shamil', style: TextStyle(fontSize: 22)),
          Text('shamil.shaimuratov@narxoz.kz'),
        ],
      ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Product product;

  const DetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              product.image,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${product.price} • ${product.category}'),
                  const SizedBox(height: 16),
                  Text(product.description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}