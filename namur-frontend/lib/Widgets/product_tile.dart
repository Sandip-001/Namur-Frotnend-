import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../provider/product_provider.dart';

import 'quantity_button.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProviderDemo>(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Image.network(product.image, height: 70, width: 70, fit: BoxFit.cover),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(product.qty.toString()),
                Text("Rs ${product.weightOrRate}/Kg",
                    style: const TextStyle(color: Colors.green)),
              ],
            ),
          ),
          Row(
            children: [
              QuantityButton(
                icon: Icons.remove,
                onPressed: () => provider.decreaseQty(product.id),
              ),
              Text("${product.qty}", style: const TextStyle(fontSize: 16)),
              QuantityButton(
                icon: Icons.add,
                onPressed: () => provider.increaseQty(product.id),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
