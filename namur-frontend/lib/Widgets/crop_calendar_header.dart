import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cropplan_provider.dart';
import '../screens/cost_estimation_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/pests_diseases_screen.dart';
import '../screens/cultivation_tips_screen.dart';
import '../screens/crop_selection_screen.dart';
import '../screens/calender_crop_details.dart';

class CropCalendarHeader extends StatelessWidget {
  final String activeScreen; // "calendar", "tips", "schedule", etc.

  const CropCalendarHeader({super.key, required this.activeScreen});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CropPlanProvider>(context);
    // ✅ DEFAULT SELECT FIRST ITEM
    if (provider.cropPlans.isNotEmpty && provider.selectedCropId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.setSelectedCrop(provider.cropPlans.first);
      });
    }
    final subCategories = [
      {
        "name": "cost_estimate".tr(),
        "key": "cost_estimate",
        "icon": "assets/images/cost.png",
      },
      {
        "name": "schedule.title".tr(),
        "key": "schedule",
        "icon": "assets/images/schedule.png",
      },
      {
        "name": "pests_control".tr(),
        "key": "pests_control",
        "icon": "assets/images/pests.png",
      },
      {
        "name": "cultivation_tip".tr(),
        "key": "cultivation_tip",
        "icon": "assets/images/cultivation.png",
      },
    ];

    return Column(
      children: [
        const SizedBox(height: 10),

        /// ---------------- TOP CROPS LIST ----------------
        SizedBox(
          height: 110, // Set to 110 to prevent overflow while staying compact
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Vertically center items in row
            children: [
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.cropPlans.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final item = provider.cropPlans[index];
                    final isSelected =
                        provider.selectedCropPlanId == item.id;

                    return GestureDetector(
                      onTap: () => provider.setSelectedCrop(item),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 70, // Fixed width for centering icons and text
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? const Color.fromRGBO(195, 255, 119, 1)
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              color: isSelected
                                  ? const Color.fromRGBO(195, 255, 119, 1)
                                  : Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.network(
                                item.productImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 80, // Match container width reasonably
                            child: Text(
                              "${item.productName}${item.landName != null ? " (${item.landName})" : ""}",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.green
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(top: 2),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              /// ADD BUTTON
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CropSelectionScreen(),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Container(
                    margin: const EdgeInsets.only(left: 6, bottom: 20), // Compensate for text height under crop box
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF83C11F),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ),
            ],
          ),
        ),

        /// ---------------- SECOND CATEGORY ROW ----------------
        Container(
          decoration: BoxDecoration(
            color: const Color.fromRGBO(195, 255, 119, 1),
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: subCategories.map((item) {
              final isTabSelected = item["key"] == activeScreen;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    // 1. Check if a crop is selected (by ID)
                    if (provider.selectedCropId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please select a crop first"),
                        ),
                      );
                      return;
                    }

                    // 2. Check if data is still loading
                    if (provider.isCropLoading) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Loading crop details, please wait..."),
                        ),
                      );
                      return;
                    }

                    // 3. Final check: Ensure detailed data (selectedCrop) exists before navigating
                    if (provider.selectedCrop == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "No calendar details available for this crop",
                          ),
                        ),
                      );
                      return;
                    }

                    // Navigate based on key
                    final String targetKey = item["key"]!;
                    if (targetKey == activeScreen) return; // Prevent redundant pushes

                    Widget targetScreen;
                    switch (targetKey) {
                      case "cultivation_tip":
                        targetScreen = const CultivationTipsScreen();
                        break;
                      case "pests_control":
                        targetScreen = const PestsDiseasesScreen();
                        break;
                      case "schedule":
                        targetScreen = const ScheduleScreen();
                        break;
                      case "cost_estimate":
                        targetScreen = CostEstimationScreen(
                          costList: provider.selectedCrop!.costEstimate,
                        );
                        break;
                      default:
                        return;
                    }

                    if (activeScreen == "calendar") {
                      // Navigate from main list
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => targetScreen),
                      );
                    } else {
                      // Switching between sub-tabs
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => targetScreen),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isTabSelected
                          ? Colors.white.withOpacity(0.5)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          item["icon"]!, 
                          height: 35, // Reduced from 60 to prevent horizontal overflow
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item["name"]!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isTabSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
