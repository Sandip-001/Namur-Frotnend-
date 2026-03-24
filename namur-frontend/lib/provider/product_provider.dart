import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ProductProviderDemo extends ChangeNotifier {
  // ------------------------
  // Existing main products
  // ------------------------
  final List<Product> _products = [
    Product(
      id: 'p1',
      title: 'tractor 900/hr',
      subtitle: 'ON RENT',
      image:
      'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2FmanAndMcs%2F02_JCB.png?alt=media&token=c90db698-f547-47fa-b226-ee4866849b7e',
      weightOrRate: '₹900 /Hr',
      location: 'Pitlali, CHITRADURGA',
      date: '23 Jun, 2024',
      runningHrs: '250 Hrs',
      rating: '4.5',
      kms: '40000 Kms',
      ownerName: 'Kumar Swamy',
      ownerContact: '+91 98765 43210',
    ),
    Product(
      id: 'p2',
      title: 'tyre',
      subtitle: 'ON RENT',
      image:
      'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2FmanAndMcs%2FTractor.png?alt=media&token=42e725b1-8142-4258-a1a4-caafd6cf9ee8',
      weightOrRate: '₹1000 /Hr',
      location: 'CHITRADURGA',
      date: '19 Jun, 2024',
      runningHrs: '180 Hrs',
      rating: '4.0',
      kms: '20000 Kms',
      ownerName: 'Ramesh',
      ownerContact: '+91 91234 56789',
    ),
    Product(
      id: 'p3',
      title: 'kuboto AWD 30 hp',
      subtitle: 'ON RENT',
      image:
      'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2FmanAndMcs%2FTractor.png?alt=media&token=42e725b1-8142-4258-a1a4-caafd6cf9ee8',
      weightOrRate: '₹800 /Hr',
      location: 'Pitlali, CHITRADURGA',
      date: '11 Jun, 2024',
      runningHrs: '300 Hrs',
      rating: '4.8',
      kms: '5000 Kms',
      ownerName: 'Suresh',
      ownerContact: '+91 99876 54321',
    ),
  ];

  // ------------------------
  // Wishlist & Cart
  // ------------------------
  final List<Product> _wishlist = [];
  final List<Product> _cart = [];

  // ------------------------
  // Orders (mock accordion data)
  // ------------------------
  final List<Map<String, dynamic>> _orders = [
    {
      'orderCode': '2500-200',
      'orderDate': '01-04-25',
      'totalAmount': 'Rs. 2000 /-',
      'paymentStatus': 'Paid',
      'paymentMethod': 'Stripe',
      'deliveryStatus': 'In Transit',
      'shippingAddress':
      'Noida Sector 63, H Block 150\nNoida, India - 201306\nPh: +91 9720940848',
      'products': [
        Product(
          id: 'p1',
          title: 'Grapes Black',
          image:
          'https://upload.wikimedia.org/wikipedia/commons/b/bb/Table_grapes_on_white.jpg',
          weightOrRate: 'Rs 10/Kg',
          status: 'Delivered',
          size: '1Kg',
          qty: 1,
        ),
        Product(
          id: 'p2',
          title: 'Orange',
          image:
          'https://upload.wikimedia.org/wikipedia/commons/c/c4/Orange-Fruit-Pieces.jpg',
          weightOrRate: 'Rs 10/Kg',
          status: 'Delivered',
          size: '1Kg',
          qty: 1,
        ),
      ],
    },
    {
      'orderCode': '2500-201',
      'orderDate': '05-05-25',
      'totalAmount': 'Rs. 1500 /-',
      'paymentStatus': 'Pending',
      'paymentMethod': 'GPay',
      'deliveryStatus': 'Processing',
      'shippingAddress':
      'MG Road, Bangalore\nPh: +91 9811122233',
      'products': [
        Product(
          id: 'p3',
          title: 'Coconut',
          image:
          'https://upload.wikimedia.org/wikipedia/commons/5/5b/Coconuts_in_tree.jpg',
          weightOrRate: 'Rs 20/Kg',
          status: 'Shipped',
          size: '2Kg',
          qty: 1,
        ),
      ],
    },
  ];

  // ------------------------
  // Getters
  // ------------------------
  List<Product> get products => _products;
  List<Product> get wishlist => _wishlist;
  List<Product> get cart => _cart;
  List<Map<String, dynamic>> get orders => _orders;

  // ------------------------
  // Product Access Helpers
  // ------------------------
  Product? getById(String id) =>
      _products.firstWhere((p) => p.id == id, orElse: () => _products.first);

  Product findById(String id) =>
      _products.firstWhere((p) => p.id == id, orElse: () => _products.first);

  // ------------------------
  // Quantity Controls
  // ------------------------
  void increaseQty(String id) {
    final p = _products.firstWhere((e) => e.id == id);
    p.qty++;
    notifyListeners();
  }

  void decreaseQty(String id) {
    final p = _products.firstWhere((e) => e.id == id);
    if (p.qty > 0) p.qty--;
    notifyListeners();
  }

  int get totalItems => _products.fold(0, (s, e) => s + e.qty);

  void resetAll() {
    for (var p in _products) {
      p.qty = 0;
    }
    notifyListeners();
  }

  // ------------------------
  // Wishlist Management
  // ------------------------
  void addToWishlist(Product product) {
    if (!_wishlist.any((p) => p.id == product.id)) {
      _wishlist.add(product);
      notifyListeners();
    }
  }

  void removeFromWishlist(Product product) {
    _wishlist.removeWhere((p) => p.id == product.id);
    notifyListeners();
  }

  // ------------------------
  // Cart Management
  // ------------------------
  void addToCart(Product product) {
    final existing = _cart.indexWhere((p) => p.id == product.id);
    if (existing >= 0) {
      _cart[existing].qty++;
    } else {
      _cart.add(product);
    }
    notifyListeners();
  }

  void removeFromCart(Product product) {
    _cart.removeWhere((p) => p.id == product.id);
    notifyListeners();
  }

  double get totalCartValue {
    double sum = 0;
    for (var p in _cart) {
      final price =
          double.tryParse(p.weightOrRate.replaceAll(RegExp(r'[^0-9.]'), '')) ??
              0;
      sum += price * p.qty;
    }
    return sum;
  }

  // ------------------------
  // Order Helpers
  // ------------------------
  void addOrder(Map<String, dynamic> newOrder) {
    _orders.insert(0, newOrder);
    notifyListeners();
  }
}
