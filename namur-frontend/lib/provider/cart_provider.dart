import 'package:flutter/material.dart';

class CartItem {
  final String imageUrl;
  final String name;
  final List<String> sizes;
  String selectedSize;
  int quantity;
  double pricePerKg;

  CartItem({
    required this.imageUrl,
    required this.name,
    required this.sizes,
    required this.selectedSize,
    required this.quantity,
    required this.pricePerKg,
  });
}

class CartProvider extends ChangeNotifier {
  List<CartItem> cartItems = [
    CartItem(
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2FfruitsAndVeg%2FRice.png?alt=media&token=f1cdb9a1-8f46-4fef-8fe4-d73cb01959d1',
      name: "Organic Onion",
      sizes: ["Size","1 KG", "2 KG", "5 KG"],
      selectedSize: "1 KG",
      quantity: 1,
      pricePerKg: 50,
    ),
    CartItem(
      imageUrl: 'https://firebasestorage.googleapis.com/v0/b/namur-5095e.appspot.com/o/helpers3%2FfruitsAndVeg%2FSweet%20Potato.png?alt=media&token=703c613d-ff31-4889-b5c1-2772faf3cc25',
      name: "Potato Premium",
      sizes: ["Size","1 KG", "2 KG", "5 KG"],
      selectedSize: "1 KG",
      quantity: 2,
      pricePerKg: 40,
    ),
  ];

  void increaseQty(int index) {
    cartItems[index].quantity++;
    notifyListeners();
  }

  void decreaseQty(int index) {
    if (cartItems[index].quantity > 1) {
      cartItems[index].quantity--;
      notifyListeners();
    }
  }

  void changeSize(int index, String newSize) {
    cartItems[index].selectedSize = newSize;
    notifyListeners();
  }

  void removeItem(int index) {
    cartItems.removeAt(index);
    notifyListeners();
  }

  double get totalPrice {
    return cartItems.fold(
      0,
          (sum, item) => sum + (item.pricePerKg * item.quantity),
    );
  }
}
