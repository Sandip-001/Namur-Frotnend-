// models/product.dart
class Product {
  final String id;
  final String title;
  final String subtitle; // e.g., ON RENT
  final String image;
  final String weightOrRate; // e.g., "₹900 /Hr" or "Rs 10/Kg"
  final String location;
  final String date; // e.g., "01-04-23"
  final String runningHrs;
  final String rating; // "4.5"
  final String kms;
  final String ownerName;
  final String ownerContact;
  final String? discount; // NEW: "20% off"
  String? size; // NEW: e.g. "1kg"
  String? status; // NEW: e.g. "Delivered", "In Transit"
  int qty;
  int price;

  Product({
    required this.id,
    required this.title,
    this.subtitle = '',
    required this.image,
    required this.weightOrRate,
    this.location = '',
    this.date = '',
    this.runningHrs = '',
    this.rating = '',
    this.kms = '',
    this.ownerName = '',
    this.ownerContact = '',
    this.discount,
    this.size,
    this.status,
    this.qty = 0,
    this.price=0
  });
}
