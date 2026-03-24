import 'package:flutter/material.dart';

class OrderTrackingStep {
  final String title;
  final String subtitle;
  final bool isCompleted;

  OrderTrackingStep({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
  });
}

class OrderTrackingProvider extends ChangeNotifier {
  final List<OrderTrackingStep> _steps = [
    OrderTrackingStep(
        title: "Order Placed",
        subtitle: "Your order has been successfully placed.",
        isCompleted: true),
    OrderTrackingStep(
        title: "Order Confirmed",
        subtitle: "Seller has confirmed your order.",
        isCompleted: true),
    OrderTrackingStep(
        title: "Shipped",
        subtitle: "Your order is on the way.",
        isCompleted: true),
    OrderTrackingStep(
        title: "Out for Delivery",
        subtitle: "Delivery agent is near your location.",
        isCompleted: false),
    OrderTrackingStep(
        title: "Delivered",
        subtitle: "Your order has been delivered.",
        isCompleted: false),
  ];

  List<OrderTrackingStep> get steps => _steps;
}
