import 'package:flutter/material.dart';

class TopCategoryBar extends StatelessWidget {
  final List<String> imageUrls;
  final bool showAddButton;
  final VoidCallback? onAddTap;

  const TopCategoryBar({
    super.key,
    required this.imageUrls,
    this.showAddButton = false,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: Row(
        children: [
          // 🔹 Overlapping circle avatars
          Stack(
            clipBehavior: Clip.none,
            children: List.generate(imageUrls.length, (index) {
              return Positioned(
                left: index * 45,
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage(imageUrls[index]),
                  ),
                ),
              );
            }),
          ),

          // 🔹 Add Button (optional)
          if (showAddButton)
            Padding(
              padding: EdgeInsets.only(left: imageUrls.length * 45 + 10),
              child: GestureDetector(
                onTap: onAddTap,
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: const BoxDecoration(
                    color: Color(0xFF83C11F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
