import 'package:flutter/material.dart';

class MemberAvatar extends StatelessWidget {
  final String imageUrl;
  final Color? tickColor;

  const MemberAvatar({
    super.key,
    required this.imageUrl,
    this.tickColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(imageUrl),
        ),
        if (tickColor != null)
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.white,
            child: Icon(Icons.check_circle, color: tickColor, size: 16),
          ),
      ],
    );
  }
}
