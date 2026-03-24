import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_namur_frontend/Widgets/custom_appbar.dart';
import '../provider/product_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProviderDemo>(context);
    final order = provider.orders.first; // show latest order for demo

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(title: 'Order Details',showBack: true,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- Order Info Card ----------------
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow('Order Code', order['orderCode'],
                        valueColor: Colors.redAccent, boldValue: true),
                    _buildRow('Order Date', order['orderDate']),
                    _buildRow('Total Amount', order['totalAmount'],
                        valueColor: Colors.redAccent, boldValue: true),
                    _buildRow('Payment Status', order['paymentStatus'],
                        valueColor: Colors.green),
                    _buildRow('Payment Method', order['paymentMethod'],
                        valueColor: Colors.grey[700]),
                    _buildRow('Delivery Status', order['deliveryStatus'],
                        valueColor: Colors.orange),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Shipping Address',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('Edit',
                              style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    ),
                    Text(
                      order['shippingAddress'],
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ---------------- Products Header ----------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  "Products Ordered",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ---------------- Product List ----------------
            ...order['products'].map<Widget>((p) {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.black12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          p.image,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Size',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  p.size ?? "1Kg",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  p.weightOrRate,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      p.status ?? "Delivered",
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {},
                                      child: const Text(
                                        "Ask Refund",
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.redAccent,
                                            decoration:
                                            TextDecoration.underline),
                                      ),
                                    ),
                                    const Icon(Icons.refresh,
                                        size: 18, color: Colors.redAccent),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {Color? valueColor, bool boldValue = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: valueColor ?? Colors.black87,
              fontWeight: boldValue ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
