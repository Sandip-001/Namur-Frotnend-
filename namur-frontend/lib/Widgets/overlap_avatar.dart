import 'package:flutter/material.dart';

class OverlappingAvatars extends StatelessWidget {
  final List<String> imageUrls;
  final double radius;
  final double overlap;

  const OverlappingAvatars({
    super.key,
    required this.imageUrls,
    this.radius = 20,
    this.overlap = 16,
  });

  @override
  Widget build(BuildContext context) {
    final double avatarSize = radius * 2;
    final double totalWidth =
        avatarSize + (imageUrls.length - 1) * overlap;

    return SizedBox(
      width: totalWidth,          // ✅ FIXED WIDTH
      height: avatarSize,         // ✅ FIXED HEIGHT
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(imageUrls.length, (index) {
          final img = imageUrls[index];
          final isAsset = !img.startsWith('http');

          return Positioned(
            left: index * overlap,
            child: CircleAvatar(
              radius: radius,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: isAsset
                  ? AssetImage(img)
                  : NetworkImage(img) as ImageProvider,
            ),
          );
        }),
      ),
    );
  }
}
