import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/string_extension.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 100,
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  width: 110,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (c, u) => Container(
                    width: 110,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  errorWidget: (c, u, e) => Container(
                    width: 110,
                    height: 100,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(product.subtitle, style: const TextStyle(color: Colors.grey)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(product.weightOrRate, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 12, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(product.location.toTitleCase(), style: const TextStyle(fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(product.date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
