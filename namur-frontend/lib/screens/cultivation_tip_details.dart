import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Widgets/custom_appbar.dart';
import '../utils/drive_url_utils.dart';

import '../models/cropplan_model.dart';

class CultivationTipDetailsScreen extends StatelessWidget {
  final CultivationTip tip;

  const CultivationTipDetailsScreen({super.key, required this.tip});

  // ------------------------- YOUTUBE THUMBNAIL EXTRACTION -------------------------
  String? getYoutubeThumbnail(String url) {
    try {
      if (url.contains("youtu.be/")) {
        final id = url.split("youtu.be/")[1];
        return "https://img.youtube.com/vi/$id/0.jpg";
      }

      if (url.contains("v=")) {
        final id = url.split("v=")[1].split("&").first;
        return "https://img.youtube.com/vi/$id/0.jpg";
      }
    } catch (_) {}

    return null;
  }

  // ------------------------- OPEN ANY URL -------------------------
  Future<void> openUrl(BuildContext context, String url) async {
    final finalUrl = toDirectOpenUrl(url);
    if (finalUrl.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No document link available.")),
        );
      }
      return;
    }

    final uri = Uri.parse(finalUrl);
    try {
      bool launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open the document.")),
        );
      }
    } catch (e) {
      debugPrint("Error launching url $finalUrl : $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open the document.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final drivePreview = toDirectOpenUrl(tip.dataUrl);
    final youtubeThumb = getYoutubeThumbnail(tip.youtubeUrl);

    return Scaffold(
      appBar: CustomAppBar(title: tip.name, showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------------- IMAGE ----------------
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                getDriveImage(tip.logoUrl),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.image_not_supported),
              ),
            ),

            const SizedBox(height: 16),

            // ---------------- DESCRIPTION ----------------
            Text(
              tip.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // ---------------- FILE SECTION ----------------
            const Text(
              "Cultivation Material",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () => openUrl(context, drivePreview),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.file_present, size: 28, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Open Attachment",
                        style: TextStyle(fontSize: 16, color: Colors.green.shade700),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ---------------- YOUTUBE SECTION ----------------
            if (tip.youtubeUrl.isNotEmpty) ...[
              const Text(
                "YouTube Video",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: () => openUrl(context, tip.youtubeUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: youtubeThumb != null
                      ? Image.network(
                    youtubeThumb,
                    height: 200,
                    width: double.infinity,    // 💥 Full width
                    fit: BoxFit.cover,         // 💥 Cover full space
                  )
                      : Container(
                    height: 200,
                    width: double.infinity,     // 💥 Full width placeholder
                    alignment: Alignment.center,
                    color: Colors.black12,
                    child: const Icon(Icons.play_circle_fill, size: 80),
                  ),
                ),
              ),


              const SizedBox(height: 25),
            ],

      /*      // ---------------- SUB STAGES ----------------
            if (tip.subStages.isNotEmpty) ...[
              const Text(
                "Sub Stages",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Column(
                children: tip.subStages.map((s) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timeline, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "${s.name} (${s.numberOfDays} days)",
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            ],*/

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String getDriveImage(String url) {
    if (url.contains("drive.google.com")) {
      try {
        final fileId = url.split("/d/")[1].split("/")[0];
        return "https://drive.google.com/uc?export=view&id=$fileId";
      } catch (e) {
        return url; // fallback if URL format unexpected
      }
    }
    return url;
  }
}
