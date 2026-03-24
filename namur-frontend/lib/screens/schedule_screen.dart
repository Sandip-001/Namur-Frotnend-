import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Widgets/custom_appbar.dart';
import '../Widgets/drawer_menu.dart';
import '../provider/cropplan_provider.dart';
import '../Widgets/crop_calendar_header.dart';
import 'calender_crop_details.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _isSaving = false;
  DateTime? _pickedDate;

  String _formatDateForDisplay(String isoOrYMD) {
    try {
      final dt = DateTime.parse(isoOrYMD);
      return DateFormat.yMMMMd().format(dt);
    } catch (_) {
      return isoOrYMD;
    }
  }

  String _formatDateForApi(DateTime d) {
    return "${d.year.toString().padLeft(4, '0')}-"
        "${d.month.toString().padLeft(2, '0')}-"
        "${d.day.toString().padLeft(2, '0')}";
  }

  Future<void> _pickAndSaveDate(
    BuildContext context,
    CropPlanProvider provider,
    int planId,
    String currentDateStr,
  ) async {
    DateTime initial;
    try {
      initial = DateTime.parse(currentDateStr);
    } catch (_) {
      initial = DateTime.now();
    }


    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate ?? initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      _pickedDate = picked;
      _isSaving = true;
    });

    final formatted = _formatDateForApi(picked);
    final ok = await provider.updatePlanningDate(planId, formatted);

    setState(() {
      _isSaving = false;
    });

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("schedule.planning_date_updated".tr())),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("schedule.planning_date_failed".tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CropPlanProvider>(context);

    CropCalendarItem? planItem;
    try {
      planItem = provider.cropPlans.firstWhere(
        (p) => p.productId == provider.selectedCropId,
      );
    } catch (_) {
      try {
        planItem = provider.cropPlans.firstWhere(
          (p) => p.id == provider.selectedCropId,
        );
      } catch (_) {
        planItem = null;
      }
    }

    final hasSelection = planItem != null;
    final imageUrl = planItem?.productImage ?? "";
    final productName = planItem?.productName ?? "";
    final landName = planItem?.landName ?? "";
    final planningDate = planItem?.planningDate ?? "";

    return Scaffold(
      appBar: CustomAppBar(title: "schedule.title".tr(), showBack: true),
      drawer: const DrawerMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CropCalendarHeader(activeScreen: "schedule"),
            const SizedBox(height: 10),
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFDFFFD4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "schedule.crop_details".tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  height: 180,
                  width: 180,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    width: 180,
                    color: Colors.grey[300],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                productName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                landName,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 24),

            // PLANTING DATE TITLE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFDFFFD4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "schedule.planting_date".tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            if (planningDate.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 4),
                child: Text(
                  _formatDateForDisplay(planningDate),
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),

            const SizedBox(height: 18),

            // CHANGE DATE BUTTON
            ElevatedButton(
              onPressed: hasSelection
                  ? () => _pickAndSaveDate(
                      context,
                      provider,
                      planItem!.id,
                      planningDate,
                    )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.black)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.black),
                        const SizedBox(width: 8),
                        Text(
                          "schedule.change_planning_date".tr(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 30),

            // START TRACKING
            ElevatedButton(
              onPressed: hasSelection
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CropCalendarDetailsScreen(),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "schedule.start_tracking".tr(),
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
