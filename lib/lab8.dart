import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const CatalogScreen(),
    );
  }
}

class Product {
  final String id;
  final String title;
  final String category;
  final double rating;
  final double price;

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.rating,
    required this.price,
  });
}

List<Product> seedProducts() => [
      const Product(id: 's1', title: 'iPhone 16 Pro', category: 'Phones', rating: 4.8, price: 999),
      const Product(id: 's2', title: 'MacBook Air M3', category: 'Laptops', rating: 4.9, price: 1199),
      const Product(id: 's3', title: 'AirPods Pro 2', category: 'Audio', rating: 4.7, price: 249),
      const Product(id: 's4', title: 'Apple Watch Ultra', category: 'Wearables', rating: 4.6, price: 799),
      const Product(id: 's5', title: 'iPad Air', category: 'Tablets', rating: 4.5, price: 599),
      const Product(id: 's6', title: 'Magic Keyboard', category: 'Accessories', rating: 4.3, price: 99),
      const Product(id: 's7', title: 'HomePod mini', category: 'Audio', rating: 4.4, price: 99),
      const Product(id: 's8', title: 'AirTag', category: 'Accessories', rating: 4.2, price: 29),
    ];

Product generateProduct(int n) {
  const names = ['Galaxy S25', 'Pixel 9', 'Sony WH-1000XM5', 'Kindle Paperwhite', 'GoPro Hero 12'];
  const cats = ['Phones', 'Phones', 'Audio', 'Books', 'Cameras'];
  final i = n % names.length;
  return Product(
    id: 'new_$n',
    title: names[i],
    category: cats[i],
    rating: 3.5 + (n % 15) / 10,
    price: 50.0 + (n * 37) % 900,
  );
}

class DeleteBackground extends StatelessWidget {
  final double radius;

  const DeleteBackground({super.key, this.radius = 0});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}

class ProductListTile extends StatelessWidget {
  final Product product;

  const ProductListTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      leading: CircleAvatar(
        backgroundColor: Colors.indigo.shade50,
        child: const Icon(Icons.shopping_bag, color: Colors.indigo),
      ),
      title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(product.category, style: const TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.star, size: 16, color: Colors.amber),
          Text(product.rating.toStringAsFixed(1)),
        ],
      ),
      trailing: Text(
        '\$${product.price.toStringAsFixed(0)}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.green,
        ),
      ),
    );
  }
}

class ProductGridCard extends StatelessWidget {
  final Product product;

  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.indigo.shade50,
              child: const Icon(Icons.shopping_bag, color: Colors.indigo),
            ),
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(product.category, style: const TextStyle(fontSize: 12)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                Text(product.rating.toStringAsFixed(1)),
              ],
            ),
            Text(
              '\$${product.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final VoidCallback onRestore;

  const EmptyState({super.key, required this.onRestore});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Catalog is Empty',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRestore,
            child: const Text('Restore initial data'),
          ),
        ],
      ),
    );
  }
}

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  List<Product> _products = seedProducts();
  bool _isGrid = false;
  int _counter = 0;

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _counter++;
      _products.insert(0, generateProduct(_counter));
    });
  }

  void _deleteProduct(Product product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    setState(() => _products.removeAt(index));

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.title} deleted'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              setState(() => _products.insert(index, product));
            },
          ),
        ),
      );
  }

  void _restoreSeed() {
    setState(() => _products = seedProducts());
  }

  Widget _dismissible(Product product, Widget child, {double radius = 0}) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: DeleteBackground(radius: radius),
      onDismissed: (_) => _deleteProduct(product),
      child: child,
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _products.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final product = _products[index];
          return _dismissible(product, ProductListTile(product: product));
        },
      ),
    );
  }

  Widget _buildGrid() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _dismissible(
            product,
            ProductGridCard(product: product),
            radius: 12,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Catalog'),
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGrid = !_isGrid),
          ),
        ],
      ),
      body: _products.isEmpty
          ? EmptyState(onRestore: _restoreSeed)
          : (_isGrid ? _buildGrid() : _buildList()),
    );
  }
}