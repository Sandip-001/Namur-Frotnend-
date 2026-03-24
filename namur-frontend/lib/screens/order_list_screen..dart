import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/product_provider.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<ProductProviderDemo>(context).orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order List'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 18,
          columns: const [
            DataColumn(label: Text('Order')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Total')),
          ],
          rows: orders.map((order) {
            return DataRow(cells: [
              DataCell(Text('#${order['orderCode']}')),
              DataCell(Text(order['orderDate'])),
              DataCell(Text(order['deliveryStatus'])),
              DataCell(Text(order['totalAmount'])),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
