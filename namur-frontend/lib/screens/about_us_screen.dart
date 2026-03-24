import 'package:flutter/material.dart';
import 'package:the_namur_frontend/Widgets/custom_appbar.dart';
import 'package:easy_localization/easy_localization.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'about_us_title'.tr(), showBack: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'about_us_heading'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              'about_us_content'.tr(),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 12),
            Text(
              'privacy_policy'.tr(),
              style: const TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
