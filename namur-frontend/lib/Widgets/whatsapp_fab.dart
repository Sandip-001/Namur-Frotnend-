import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class WhatsAppButton extends StatelessWidget {
  final String phoneNumber; // Must include country code, no '+'
  final String message;
  final String imagePath;
  final double size;

  const WhatsAppButton({
    super.key,
    required this.phoneNumber, // Example: "919876543210"
    this.message = "Hello! I’d like to know more.",
    this.imagePath = 'assets/images/whatsapp.png',
    this.size = 70,
  });

  Future<void> _openWhatsApp(BuildContext context) async {
    String formattedPhone = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (formattedPhone.length == 10) {
      formattedPhone = '91$formattedPhone';
    }

    final Uri nativeUri = Uri.parse(
      "whatsapp://send?phone=$formattedPhone&text=${Uri.encodeComponent(message)}",
    );

    final Uri webUri = Uri.parse(
      "https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}",
    );

    try {
      if (kIsWeb) {
        // On web, always use wa.me link (whatsapp:// scheme doesn't work in browsers)
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      }

      // 1. Try launching the native WhatsApp app directly
      bool launched = await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      
      // 2. If it fails (e.g., WhatsApp not installed or intent blocked), fallback to Web URL
      if (!launched) {
        launched = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }

      // 3. If both fail, show an error message
      if (!launched) {
        _showErrorSnackBar(context, "Could not open WhatsApp. Please install it.");
      }
    } catch (e) {
      debugPrint("Error launching WhatsApp: $e");
      // Try fallback if exception was thrown by native intent
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (fallbackErr) {
        debugPrint("Fallback also failed: $fallbackErr");
        _showErrorSnackBar(context, "Something went wrong. Try again later.");
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openWhatsApp(context),
      child: Image.asset(
        imagePath,
        height: size,
        width: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
