import 'package:flutter/material.dart';

class HexagonTile extends StatelessWidget {
  final String hexagonImage; // Always asset for hexagon shape
  final String iconImage; // Asset OR Network
  final String title;
  final VoidCallback? onTap;

  const HexagonTile({
    super.key,
    required this.hexagonImage,
    required this.iconImage,
    required this.title,
    this.onTap,
  });

  bool _isNetworkImage(String url) {
    return url.startsWith("http") || url.startsWith("https");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // 🛑 Hexagon Shape
              Image.asset(
                hexagonImage,
                width: 100,
                height: 100,
                fit: BoxFit.contain,
              ),

              // 🟢 Dynamic Icon (Network or Asset)
              _isNetworkImage(iconImage)
                  ? Image.network(
                      iconImage,
                      width: 55,
                      height: 55,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey,
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          width: 30,
                          height: 30,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                    )
                  : Image.asset(
                      iconImage,
                      width: 55,
                      height: 55,
                      fit: BoxFit.contain,
                    ),
            ],
          ),

          // 🟡 Title text
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
