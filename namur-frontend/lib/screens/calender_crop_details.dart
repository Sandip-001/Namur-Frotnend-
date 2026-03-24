import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';

import '../Widgets/crop_calendar_header.dart';
import '../Widgets/custom_appbar.dart';
import '../Widgets/drawer_menu.dart';
import '../provider/cropplan_provider.dart';
import 'calender_screen.dart';

class CropCalendarDetailsScreen extends StatefulWidget {
  const CropCalendarDetailsScreen({super.key});

  @override
  State<CropCalendarDetailsScreen> createState() =>
      _CropCalendarDetailsScreenState();
}

class _CropCalendarDetailsScreenState extends State<CropCalendarDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Defer provider fetch to avoid notifyListeners during build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<CropPlanProvider>(context, listen: false).fetchCropPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CropPlanProvider>(context);

    final subCategories = [
      {
        "name": "cost_estimate".tr(),
        "key": "cost_estimate",
        "icon": "assets/images/cost.png",
      },
      {
        "name": "schedule",
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

    return Scaffold(
      appBar: CustomAppBar(title: "crop_calendar_title".tr(), showBack: true),
      drawer: const DrawerMenu(),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            /// ---------------- TOP CROPS LIST ----------------
            CropCalendarHeader(activeScreen: "calendar"),

            const SizedBox(height: 20),

            /// ---------------- CALENDAR EVENTS TITLE & STOP TRACKING ----------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    "calendar_events".tr(),
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () async {
                        final provider = Provider.of<CropPlanProvider>(
                          context,
                          listen: false,
                        );

                        if (provider.selectedCropId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("No crop selected"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        bool ok = await provider.stopTracking(
                          provider.selectedCropPlanId!,
                        );

                        if (!mounted) return;

                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Tracking stopped successfully"),
                            ),
                          );

                          // ✅ IF NO CROPS LEFT → GO TO CROP SELECTION SCREEN
                          if (provider.cropPlans.isEmpty) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CalendarScreen(),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Failed to stop tracking"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            /// ---------------- EVENTS LIST ----------------
            if (provider.isLoading || provider.isCropLoading)
              const Center(child: CircularProgressIndicator())
            else if (provider.cropPlans.isEmpty)
              const Center(child: Text("No crops available"))
            else if (provider.selectedCropId == null)
              const Center(child: Text("Select a crop to view calendar"))
            else if (provider.selectedCrop != null)
              _buildCalendarEvents(provider)
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "No calendar data found for this crop.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// ---------------- CROPS IMAGE CARD ----------------
  Widget CropPlanImageCard({
    required CropCalendarItem item,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 65,
            height: 65,
            margin: const EdgeInsets.symmetric(horizontal: 4),
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
              child: Image.network(item.productImage, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 80,
            child: Text(
              item.productName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarEvents(CropPlanProvider provider) {
    final crop = provider.selectedCrop!;
    final cropPlan = provider.cropPlans.cast<CropCalendarItem?>().firstWhere(
      (p) => p?.productId == provider.selectedCropId,
      orElse: () => null,
    );
    
    if (cropPlan == null) {
      return const Center(child: Text("Crop details not found."));
    }

    final planningDate = cropPlan.planningDate;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(crop.cultivationTips.length, (stageIndex) {
            final tip = crop.cultivationTips[stageIndex];
            final stageNumber = stageIndex + 1;

            return Container(
              margin: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Stage $stageNumber",
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFBDBDBD),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: List.generate(tip.subStages.length, (rowIndex) {
                        final sub = tip.subStages[rowIndex];
                        final days = int.tryParse(sub.numberOfDays.toString()) ?? 0;
                        final calculatedDate = provider.addDaysToPlanningDate(
                          planningDate,
                          days,
                        );
                        final dateLabel = _formatStageDateLabel(calculatedDate);
                        final isToday = dateLabel == "Today";
                        final isLast = rowIndex == tip.subStages.length - 1;
                        final subName = sub.name ?? '';

                        return _buildStageTableRow(
                          dateLabel: dateLabel,
                          subName: subName,
                          isToday: isToday,
                          isLast: isLast,
                          showTickIcon: rowIndex == 0,
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStageTableRow({
    required String dateLabel,
    required String subName,
    required bool isToday,
    required bool isLast,
    required bool showTickIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFFA8D85B) : Colors.white,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: Color(0xFFD0D0D0), width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 118,
            child: Text(
              "$dateLabel:",
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              subName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 6),
          _buildStaticStageIcon(showTickIcon),
        ],
      ),
    );
  }

  Widget _buildStaticStageIcon(bool showTickIcon) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: showTickIcon ? const Color(0xFF76C442) : const Color(0xFFC3FF77),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF5AA62C), width: 1.2),
      ),
      child: Icon(
        showTickIcon ? Icons.check : Icons.add,
        color: showTickIcon ? Colors.white : Colors.green,
        size: 15,
      ),
    );
  }

  String _formatStageDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final current = DateTime(date.year, date.month, date.day);

    if (current == today) {
      return "Today";
    }

    if (current == tomorrow) {
      return "tomorrow";
    }

    return DateFormat("dd-MMM-yy").format(date);
  }
}
