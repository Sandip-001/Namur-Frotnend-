import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_namur_frontend/screens/subcategory_ads_screen.dart';

import '../Widgets/custom_dropdown.dart';
import '../Widgets/custom_appbar.dart';
import '../Widgets/drawer_menu.dart';
import '../Widgets/custom_textfield.dart';
import '../provider/land_provider.dart';
import '../provider/crop_selection_provider.dart';
import '../utils/api_url.dart';
import 'calender_crop_details.dart';
import 'edit_profile_screen.dart';

class CropSelectionScreen extends StatefulWidget {
  const CropSelectionScreen({super.key});

  @override
  State<CropSelectionScreen> createState() => _CropSelectionScreenState();
}

class _CropSelectionScreenState extends State<CropSelectionScreen> {
  late TextEditingController areaController;
  bool isLoading = false;
  List<AdItem> adsList = [];
  bool isAdsLoading = false;

  @override
  void initState() {
    super.initState();
    areaController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LandDetailsProvider>(
        context,
        listen: false,
      ).fetchLandsByUser();

      fetchAdsByDistrict();
    });
  }

  @override
  void dispose() {
    areaController.dispose();
    super.dispose();
  }

  Future<void> fetchAdsByDistrict() async {
    setState(() => isAdsLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final district = prefs.getString("district");

    try {
      final url = Uri.parse(ApiConstants.filterAdsByDistrict(district!));

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        adsList = data.map((e) => AdItem.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Ads API Error: $e");
    } finally {
      setState(() => isAdsLoading = false);
    }
  }

  Future<void> createCropPlan() async {
    final cropProvider = Provider.of<CropSelectionProvider>(
      context,
      listen: false,
    );
    final landProvider = Provider.of<LandDetailsProvider>(
      context,
      listen: false,
    );

    if (!cropProvider.isFormComplete) return;

    setState(() => isLoading = true);
    String planningDate = '';
    if (cropProvider.plantingDate != null) {
      // Assuming cropProvider.plantingDate is in "DD-MM-YYYY" format
      final parts = cropProvider.plantingDate!.split('-');
      if (parts.length == 3) {
        final day = parts[0].padLeft(2, '0');
        final month = parts[1].padLeft(2, '0');
        final year = parts[2];
        planningDate = '$year-$month-$day';
      }
    }
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('uid');
    if (userId == null) return;
    final landId = landProvider.selectedLand?.id ?? 0;
    final productId = cropProvider.selectedCropId ?? 0;

    final area = double.tryParse(cropProvider.areaQty ?? '') ?? 0;

    final url = Uri.parse(ApiConstants.createcropPlan());

    final body = jsonEncode({
      "user_id": userId,
      "land_id": landId,
      "product_id": productId,
      "area_acres": area,
      "planning_date": planningDate,
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      final data = jsonDecode(response.body);
      print(response.statusCode);
      print(response.statusCode);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final message = data['message'] ?? 'Crop plan createddddd';

        // Show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.orange),
        );
        print("coming here");
        // Small delay so snackbar is visible before navigation
        await Future.delayed(const Duration(milliseconds: 300));
        Provider.of<CropSelectionProvider>(context, listen: false).resetForm();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CropCalendarDetailsScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Something went wrong'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.orange),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cropProvider = Provider.of<CropSelectionProvider>(context);

    // Sync controller text with provider
    areaController.text = cropProvider.areaQty ?? "";

    return Scaffold(
      appBar: CustomAppBar(
        title: "crop_calendar_title".tr(),
        showBack: true,
        extraActions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            padding: const EdgeInsets.only(right: 8.0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: const DrawerMenu(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "select_farm_crop".tr(),
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. SELECT LAND
                  Consumer<LandDetailsProvider>(
                    builder: (context, landProvider, _) {
                      if (landProvider.isLoadingList) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (landProvider.lands.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Disabled dropdown UI
                            AbsorbPointer(
                              absorbing: true, // disable
                              child: CustomDropdown(
                                hint: "No lands found",
                                value: "No lands found",
                                items: const [
                                  "No lands found",
                                ], // only one option
                                fillColor: const Color(0xFFFFE6E6),
                                onChanged: (_) {},
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Warning text
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: const Text(
                                "Please add a land first",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      final landNames = landProvider.lands
                          .map((land) => land.landName)
                          .toList();

                      return Consumer<CropSelectionProvider>(
                        builder: (context, cropProvider, _) {
                          final safeValue =
                              landNames.contains(cropProvider.selectedLand)
                              ? cropProvider.selectedLand
                              : null;

                          return CustomDropdown(
                            hint: "select_land".tr(),
                            value: safeValue,
                            items: landNames,
                            fillColor: const Color(0xFFFFE6E6),
                            onChanged: (val) async {
                              cropProvider.setLand(val!);
                              cropProvider.setCrop(val);

                              final selectedLand = landProvider.lands
                                  .firstWhere((ln) => ln.landName == val);
                              landProvider.selectLand(selectedLand);

                              await cropProvider.fetchCropList(
                                landId: selectedLand.id,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // 2. SELECT CROP
                  Consumer<CropSelectionProvider>(
                    builder: (context, cropProvider, _) {
                      if (cropProvider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final cropNames = cropProvider.cropList
                          .map((e) => e.productName)
                          .toList();

                      final safeValue =
                          cropNames.contains(cropProvider.selectedCrop)
                          ? cropProvider.selectedCrop
                          : null;

                      return CustomDropdown(
                        hint: "select_crop".tr(),
                        value: safeValue,
                        items: cropNames,
                        fillColor: const Color(0xFFFFE6E6),
                        onChanged: (val) {
                          cropProvider.setCrop(val!);
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // 3. DATE PICKER
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: cropProvider.plantingDate != null
                            ? DateTime.tryParse(cropProvider.plantingDate!) ??
                                  DateTime.now()
                            : DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );

                      if (picked != null) {
                        cropProvider.setDate(
                          "${picked.day}-${picked.month}-${picked.year}",
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 0.75,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFFFE6E6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cropProvider.plantingDate ?? "planting_date".tr(),
                              style: TextStyle(
                                color: cropProvider.plantingDate == null
                                    ? Colors.grey
                                    : Colors.black,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.green,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. AREA FIELD
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.90,
                    child: CustomTextField(
                      hint: "select_area_qty".tr(),
                      controller: areaController,
                      fillColor: const Color(0xFFFFE6E6),
                      onChanged: (val) {
                        cropProvider.setArea(val);
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: cropProvider.isFormComplete && !isLoading
                          ? createCropPlan
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cropProvider.isFormComplete
                            ? const Color(0xFF1E7A3F)
                            : Colors.grey,
                        minimumSize: const Size(120, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "track".tr(),
                              style: const TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // TRACK BUTTON
            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  const Text(
                    "2. Seeds, Fertilizer & Medicine",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  /// ITEMS ROW
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ItemWidget(
                        image: 'assets/images/seed.png',
                        label: 'Seeds',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SubCategoryAdsScreen(
                                subcategory: "Seeds",
                              ),
                            ),
                          );
                        },
                      ),
                      _ItemWidget(
                        image: 'assets/images/medicine.png',
                        label: 'Fertilizer',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SubCategoryAdsScreen(
                                subcategory: "Fertilizer",
                              ),
                            ),
                          );
                        },
                      ),
                      _ItemWidget(
                        image: 'assets/images/pest.png',
                        label: 'Medicine',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SubCategoryAdsScreen(
                                subcategory:
                                    "medicine", // ⚠️ use API expected value
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemWidget extends StatelessWidget {
  final String image;
  final String label;
  final VoidCallback? onTap;

  const _ItemWidget({required this.image, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Image.asset(image, height: 48, width: 48),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class AdItem {
  final String title;
  final String image;

  AdItem({required this.title, required this.image});

  factory AdItem.fromJson(Map<String, dynamic> json) {
    return AdItem(
      title: json["title"] ?? "",
      image: (json["images"] != null && json["images"].isNotEmpty)
          ? json["images"][0]["url"]
          : "",
    );
  }
}
