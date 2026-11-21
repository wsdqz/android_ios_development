import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

void main() {
  runApp(const MyApp());
}

class Product extends Equatable {
  final String id;
  final String title;
  final double price;

  const Product({
    required this.id,
    required this.title,
    required this.price,
  });

  @override
  List<Object?> get props => [id, title, price];
}

const products = [
  Product(id: '1', title: 'iPhone 16 Pro', price: 999),
  Product(id: '2', title: 'MacBook Air M3', price: 1199),
  Product(id: '3', title: 'AirPods Pro 2', price: 249),
  Product(id: '4', title: 'Apple Watch Ultra', price: 799),
  Product(id: '5', title: 'iPad Air', price: 599),
];

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final String username;
  final String email;

  const AuthSuccess({required this.username, required this.email});

  @override
  List<Object?> get props => [username, email];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthInitial());

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    await Future.delayed(const Duration(seconds: 1));

    if (email.trim() == 'student@narxoz.kz' && password == '123456') {
      emit(const AuthSuccess(
        username: 'Student',
        email: 'student@narxoz.kz',
      ));
    } else {
      emit(const AuthError('Invalid credentials'));
    }
  }
}

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddProductEvent extends CartEvent {
  final Product product;
  const AddProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveProductEvent extends CartEvent {
  final String productId;
  const RemoveProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ClearCartEvent extends CartEvent {
  const ClearCartEvent();
}

class CartState extends Equatable {
  final List<Product> items;

  const CartState({this.items = const []});

  int get count => items.length;

  double get totalPrice => items.fold(0.0, (sum, item) => sum + item.price);

  @override
  List<Object?> get props => [items];
}

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddProductEvent>((event, emit) {
      emit(CartState(items: [...state.items, event.product]));
    });

    on<RemoveProductEvent>((event, emit) {
      final updatedItems = List<Product>.from(state.items);
      final index = updatedItems.indexWhere((item) => item.id == event.productId);

      if (index >= 0) {
        updatedItems.removeAt(index);
      }

      emit(CartState(items: updatedItems));
    });

    on<ClearCartEvent>((event, emit) {
      emit(const CartState());
    });
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (_) => AuthCubit()),
        BlocProvider<CartBloc>(create: (_) => CartBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'student@narxoz.kz');
  final _passController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else if (state is AuthSuccess) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CatalogScreen()),
              );
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                if (state is AuthLoading)
                  const CircularProgressIndicator()
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<AuthCubit>().login(
                          _emailController.text,
                          _passController.text,
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              return IconButton(
                icon: Badge(
                  label: Text('${state.count}'),
                  isLabelVisible: state.count > 0,
                  child: const Icon(Icons.shopping_cart),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];

          return ListTile(
            title: Text(product.title),
            subtitle: Text('\$${product.price.toStringAsFixed(0)}'),
            trailing: ElevatedButton(
              onPressed: () => context.read<CartBloc>().add(AddProductEvent(product)),
              child: const Text('Add'),
            ),
          );
        },
      ),
    );
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const Center(child: Text('Cart is empty'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final product = state.items[index];

                    return ListTile(
                      title: Text(product.title),
                      subtitle: Text('\$${product.price.toStringAsFixed(0)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () =>
                            context.read<CartBloc>().add(RemoveProductEvent(product.id)),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Total: \$${state.totalPrice.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.read<CartBloc>().add(const ClearCartEvent()),
                        child: const Text('Clear All'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}