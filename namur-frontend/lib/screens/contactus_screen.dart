import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Widgets/custom_appbar.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  // Call function
  void _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '8553900408');
    await launchUrl(phoneUri);
  }

  // Email function
  void _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'inkaanalysis@gmail.com',
    );
    await launchUrl(emailUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title:"Contact Us",
        showBack: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Contact Us",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            const Text(
              "Have questions or need help? We're here for you!",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

             // Number
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• "),
                Expanded(
                  child: Row(
                    children: [
                      const Text("Number: ",
                          style: TextStyle(fontSize: 16)),
                      GestureDetector(
                        onTap: _launchPhone,
                        child: const Text(
                          "+91 8553900408",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Email
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• "),
                Expanded(
                  child: Row(
                    children: [
                      const Text("Email: ", style: TextStyle(fontSize: 16)),
                      GestureDetector(
                        onTap: _launchEmail,
                        child: const Text(
                          "inkaanalysis@gmail.com",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text(
              "Feel free to reach out anytime. "
                  "Thank you for using Namur!",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
