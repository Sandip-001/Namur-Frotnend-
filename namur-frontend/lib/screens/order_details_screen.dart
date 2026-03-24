import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Widgets/custom_appbar.dart';
import '../provider/product_provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final order =
        Provider.of<ProductProviderDemo>(context, listen: false).orders.first;

    return Scaffold(
      appBar: CustomAppBar(title: 'Order Details',showBack: true,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepper(),
            const SizedBox(height: 16),
            _buildOrderInfo(order),
          ],
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: const [
        _StepIcon(icon: Icons.assignment_turned_in, label: 'Order Place', active: true),
        _StepIcon(icon: Icons.check_circle, label: 'Confirmed', active: true),
        _StepIcon(icon: Icons.local_shipping, label: 'On Delivery', active: false),
        _StepIcon(icon: Icons.done_all, label: 'Delivered', active: false),
      ],
    );
  }

  Widget _buildOrderInfo(Map<String, dynamic> order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       // const Divider(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromRGBO(0,0,0,0.2))
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Order Code', order['orderCode']),
                _infoRow('Order Date', order['orderDate']),
                _infoRow('Total Amount', order['totalAmount'], bold: true, color: Colors.red),
                _infoRow('Payment Status', order['paymentStatus']),
                _infoRow('Payment Method', order['paymentMethod']),
                const SizedBox(height: 12),
                _infoRow('Delivery Status', order['deliveryStatus']),
                const SizedBox(height: 12),
                const Text('Shipping Address',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(order['shippingAddress']),
              ],
            ),
          ),
        ),
       // const Divider(),
        const SizedBox(height: 25),
        Center(
          child: const Text('Ordered Products',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        ...order['products'].map<Widget>((p) => ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Image.network(p.image, width: 40, height: 40),
          title: Text(p.title),
          trailing: Text(p.weightOrRate),
        )),
      ],
    );
  }

  Widget _infoRow(String title, String value,
      {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
        ],
      ),
    );
  }
}

class _StepIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _StepIcon(
      {required this.icon, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: active ? Colors.green : Colors.grey),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: active ? Colors.green : Colors.grey)),
      ],
    );
  }
}
