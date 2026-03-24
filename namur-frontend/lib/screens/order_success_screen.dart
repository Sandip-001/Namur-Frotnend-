import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_namur_frontend/Widgets/custom_appbar.dart';
import 'package:the_namur_frontend/screens/orders_screen.dart';
import '../provider/product_provider.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProviderDemo>(context);
    final order = provider.orders.first; // Mock latest order

    return Scaffold(
      appBar: CustomAppBar(title: 'Order Details'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 90),
            const SizedBox(height: 12),
            const Text(
              'Thanks for Order',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...order['products'].map<Widget>(
              (p) => GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => OrdersScreen()),
                  );
                },
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color.fromRGBO(0, 0, 0, 0.2)),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            p.image,
                            width: 80,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 25),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    p.title,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '1 Kg',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      // fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '20% Off',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      //fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    'Rs.10/Kg',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      //fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.green,
                                      size: 40,
                                    ),
                                    onPressed: () {},
                                  ),
                                  const SizedBox(width: 12),

                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.green,
                                      size: 40,
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Track Order',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  //OrderTrackingScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
