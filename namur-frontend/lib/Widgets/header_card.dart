import 'package:flutter/material.dart';
import 'package:the_namur_frontend/utils/my_theme.dart';

class HeaderCard extends StatelessWidget {
  final String profileUrl;
  final String friendsText;
  final String groupsText;
  final String societyText;
  final double? progressValue; // OPTIONAL FIELD

  const HeaderCard({
    super.key,
    required this.profileUrl,
    required this.friendsText,
    required this.groupsText,
    required this.societyText,
    required this.progressValue,
  });

  @override
  Widget build(BuildContext context) {
    // Show progress only if NOT null AND > 0
    // Show progress only if NOT null AND > 0
    final bool showProgress = progressValue != null && progressValue! > 0;

    // Convert percentage to 0–1 range
    final double progress = showProgress
        ? (progressValue! / 100).clamp(0.0, 1.0)
        : 0;

    // Percentage text
    final int progressPercent = showProgress ? progressValue!.toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MyTheme.green_neon,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(profileUrl),
                    ),
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(width: 25),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friendsText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        groupsText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        societyText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // ⭐ Show only if progressValue > 0
            if (showProgress) const SizedBox(height: 10),
            if (showProgress)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Profile Completion",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "$progressPercent%",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

            if (showProgress) const SizedBox(height: 6),
            if (showProgress)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress, // ✅ now correct
                  minHeight: 10,
                  // ignore: deprecated_member_use
                  backgroundColor: Colors.white.withOpacity(0.7),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
