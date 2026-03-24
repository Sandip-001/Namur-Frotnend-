import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Widgets/custom_appbar.dart';
import '../provider/cropplan_provider.dart';
import '../widgets/crop_calendar_header.dart';
import 'cultivation_tip_details.dart';


class CultivationTipsScreen extends StatelessWidget {
  const CultivationTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CropPlanProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Cultivation Tips", showBack: true),

      body: Column(
        children: [
          /// ---- REUSABLE HEADER ----
          const CropCalendarHeader(activeScreen: "tips"),

          /// ---- BODY ----
          Expanded(
            child: provider.selectedCrop == null
                ? const Center(
              child: Text(
                "Please select a crop",
                style: TextStyle(fontSize: 18),
              ),
            )
                : _buildGrid(context, provider),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context, CropPlanProvider provider) {
    final tips = provider.selectedCrop!.cultivationTips;

    if (tips.isEmpty) {
      return const Center(
        child: Text("No cultivation tips available"),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: .7,
      ),
      itemCount: tips.length,
      itemBuilder: (context, index) {
        final tip = tips[index];

        return GestureDetector(
          onTap: () {
            print("Original: ${tip.logoUrl}");
            print("Converted: ${getDriveImage(tip.logoUrl)}");

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CultivationTipDetailsScreen(
                tip: tip,
                ),
              ),
            );
          },
          child: Column(
            children: [
              Container(
                height: 80,
                width: 80,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.network(
                  getDriveImage(tip.logoUrl),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "${index + 1}. ${tip.name}",
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              )
            ],
          ),
        );
      },
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
