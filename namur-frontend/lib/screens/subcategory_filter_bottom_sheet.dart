import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ads_filter_model.dart';
import '../provider/user_provider.dart';

class SubCategoryFilterBottomSheet extends StatefulWidget {
  final String subcategory;

  const SubCategoryFilterBottomSheet({super.key, required this.subcategory});

  @override
  State<SubCategoryFilterBottomSheet> createState() => _SubCategoryFilterBottomSheetState();
}

class _SubCategoryFilterBottomSheetState extends State<SubCategoryFilterBottomSheet> {
  int selectedTab = 0; // 0=Price, 1=Location
  String priceSort = "low";
  String? selectedDistrict;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userP = context.read<UserProvider>();
      if (userP.user == null) {
        await userP.loadUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: Column(
          children: [
            /// HEADER
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              color: Colors.green,
              child: Row(
                children: [
                   Text(
                    "Filter - ${widget.subcategory}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            /// BODY with Sidebar
            Expanded(
              child: Row(
                children: [
                  /// LEFT MENU (Sidebar)
                  Container(
                    width: 120,
                    color: Colors.grey.shade200,
                    child: Column(
                      children: [
                        _leftItem("Price", 0),
                        _leftItem("Location", 1),
                      ],
                    ),
                  ),

                  /// RIGHT CONTENT
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _buildRightView(),
                    ),
                  ),
                ],
              ),
            ),

            /// SHOW RESULT BUTTON
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      AdsFilter(
                        productId: 0, 
                        sort: priceSort == "low"
                            ? "price_low_to_high"
                            : "price_high_to_low",
                        district: selectedDistrict,
                      ),
                    );
                  },
                  child: const Text(
                    "Show Results",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leftItem(String title, int index) {
    final bool selected = selectedTab == index;
    return InkWell(
      onTap: () => setState(() => selectedTab = index),
      child: Container(
        height: 50,
        width: double.infinity,
        color: selected ? Colors.white : Colors.grey.shade200,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildRightView() {
    switch (selectedTab) {
      case 0: return _priceView();
      case 1: return _locationView();
      default: return const SizedBox();
    }
  }

  Widget _priceView() {
    return Column(
      children: [
        _radioTile("Price (low to high)", "low"),
        _radioTile("Price (high to low)", "high"),
      ],
    );
  }

  Widget _radioTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: priceSort,
        activeColor: Colors.green,
        title: Text(title),
        onChanged: (v) => setState(() => priceSort = v!),
      ),
    );
  }

  Widget _locationView() {
    return Consumer<UserProvider>(
      builder: (context, userP, _) {
        final user = userP.user;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final district = (user.district ?? "").trim();
        if (district.isEmpty) {
          return const Center(child: Text("No district found in profile"));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select District",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListTile(
                title: Text(district),
                trailing: Icon(
                  selectedDistrict == district ? Icons.check_box : Icons.check_box_outline_blank,
                  color: selectedDistrict == district ? Colors.green : Colors.grey,
                ),
                onTap: () {
                  setState(() {
                    selectedDistrict = (selectedDistrict == district) ? null : district;
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
