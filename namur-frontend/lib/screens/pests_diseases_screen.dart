import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

import '../Widgets/crop_calendar_header.dart';
import '../Widgets/custom_appbar.dart';
import '../Widgets/drawer_menu.dart';
import '../provider/cropplan_provider.dart';
import 'pest_document_viewer_screen.dart';

class PestsDiseasesScreen extends StatelessWidget {
  const PestsDiseasesScreen({super.key});

  // Stage colors for UI
  final List<Color> stageColors = const [
    Color(0xFFDFF2B2),
    Color(0xFFF8DADA),
    Color(0xFFE3D8F8),
    Color(0xFFB2F2F0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "crop_calendar.pests_diseases".tr(),
        showBack: true,
      ),
      drawer: const DrawerMenu(),

      body: Consumer<CropPlanProvider>(
        builder: (context, provider, child) {
          final crop = provider.selectedCrop;

          if (crop == null) {
            return Column(
              children: [
                const CropCalendarHeader(activeScreen: "pests_control"),
                const Spacer(),
                const Text("No crop selected", style: TextStyle(color: Colors.grey)),
                const Spacer(),
              ],
            );
          }

          return Column(
            children: [
              /// TOP CATEGORY HEADER (tabs)
              const CropCalendarHeader(activeScreen: "pests_control"),

              const SizedBox(height: 10),

              /// STAGES LIST
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: crop.stagesSelection.length,
                  itemBuilder: (context, index) {
                    final stage = crop.stagesSelection[index];
                    final color = stageColors[index % stageColors.length];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Stage Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${index + 1}. ${stage.cultivationName}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// Problems (pests/diseases)
                        if (stage.problems.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "crop_calendar.no_pest_data".tr(),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Wrap(
                              spacing: 20,
                              runSpacing: 15,
                              children: stage.problems.map((problem) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PestDocumentViewerScreen(
                                          name: problem.name,
                                          documentUrl: problem.documentUrl,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF5F5F5),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            getDriveImage(problem.logoUrl),
                                            height: 80,
                                            width: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.bug_report),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      SizedBox(
                                        width: 90,
                                        child: Text(
                                          problem.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Converts Google Drive link → Direct preview image link
  String getDriveImage(String url) {
    if (url.contains("drive.google.com")) {
      try {
        final fileId = url.split("/d/")[1].split("/")[0];
        return "https://drive.google.com/uc?export=view&id=$fileId";
      } catch (e) {
        return url;
      }
    }
    return url;
  }
}
