import 'package:flutter/material.dart';

class ReportAdScreen extends StatefulWidget {
  const ReportAdScreen({super.key});

  @override
  State<ReportAdScreen> createState() => _ReportAdScreenState();
}

class _ReportAdScreenState extends State<ReportAdScreen> {
  String? selectedReason;

  final List<String> reportReasons = [
    "Product No More Available",
    "Incomplete / Wrong Information",
    "Bad Quality Product",
    "Bad Text / Language / Ad",
    "Ad Getting Repeated",
    "Fake / Fraud Seller",
    "Scam / Misleading Ad",
    "Others",
  ];

  String get descriptionText {
    switch (selectedReason) {
      case "Product No More Available":
        return "This product is no longer available for purchase.";
      case "Incomplete / Wrong Information":
        return "The ad has missing or incorrect details.";
      case "Bad Quality Product":
        return "The product quality is very poor.";
      case "Bad Text / Language / Ad":
        return "The ad contains bad or inappropriate language.";
      case "Ad Getting Repeated":
        return "The same ad is being posted multiple times.";
      case "Fake / Fraud Seller":
        return "The seller appears to be fake or fraudulent.";
      case "Scam / Misleading Ad":
        return "The ad is misleading or a scam.";
      default:
        return "Please describe the issue clearly.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: const Text(
          "Report Add/Seller",
          style: TextStyle(color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please Provide More Info About Issue\nIt Will Help To Alert Others",
              style: TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 20),

            // ---------------- DROPDOWN ----------------
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedReason,
                  hint: const Text("Select Reason For Report"),
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                  items: reportReasons.map((reason) {
                    return DropdownMenuItem(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedReason = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ---------------- DESCRIPTION BOX ----------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Description",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    descriptionText,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ---------------- BUTTON ----------------
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: selectedReason == null ? null : () {
                  // TODO: API call
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Report Post",
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
