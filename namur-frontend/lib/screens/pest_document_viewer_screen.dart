import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/drive_url_utils.dart';

class PestDocumentViewerScreen extends StatelessWidget {
  final String name;
  final String documentUrl;

  const PestDocumentViewerScreen({
    super.key,
    required this.name,
    required this.documentUrl,
  });

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
    final cleanUrl = toDirectOpenUrl(documentUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: const Color(0xFF83C11F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),

              const Icon(
                Icons.insert_drive_file,
                size: 120,
                color: Colors.grey,
              ),

              const SizedBox(height: 20),

              Text(
                "document_preview".tr(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: () => openUrl(context, cleanUrl),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF83C11F),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.open_in_new, color: Colors.white),
                label: Text(
                  "open_document".tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "external_note".tr(),
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
