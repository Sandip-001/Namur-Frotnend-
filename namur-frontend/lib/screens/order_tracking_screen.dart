import 'package:flutter/material.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  final List<Map<String, dynamic>> _steps = const [
    {"title": "Order Placed", "date": "12 Oct 2025", "isDone": true},
    {"title": "Packed", "date": "13 Oct 2025", "isDone": true},
    {"title": "Shipped", "date": "14 Oct 2025", "isDone": true},
    {"title": "Out for Delivery", "date": "", "isDone": false},
    {"title": "Delivered", "date": "", "isDone": false},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _steps.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final step = _steps[index];
          final isLast = index == _steps.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Timeline line + dot
              Column(
                children: [
                  // Dot
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: step["isDone"] ? Colors.green : Colors.grey[300],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: step["isDone"]
                            ? Colors.green
                            : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                  ),
                  // Line
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 60,
                      color: _steps[index + 1]["isDone"]
                          ? Colors.green
                          : Colors.grey[300],
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // 🔹 Step info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step["title"],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: step["isDone"] ? Colors.green : Colors.grey[700],
                        ),
                      ),
                      if (step["date"] != "")
                        Text(
                          step["date"],
                          style: const TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );

  }
}
