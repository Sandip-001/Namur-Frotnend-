import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/user_provider.dart';

class SimpleFilterBottomSheet extends StatefulWidget {
  const SimpleFilterBottomSheet({super.key});

  @override
  State<SimpleFilterBottomSheet> createState() =>
      _SimpleFilterBottomSheetState();
}

class _SimpleFilterBottomSheetState extends State<SimpleFilterBottomSheet> {
  int selectedTab = 0; // 0 = Price, 1 = Location

  String priceSort = "low";

  String? selectedDistrict;
  String? selectedTaluk;
  String? selectedPanchayat;
  String? selectedVillage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userP = context.read<UserProvider>();
      if (userP.user == null) {
        await userP.fetchProfile();
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
                  const Text(
                    "Filter",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            /// BODY
            Expanded(
              child: Row(
                children: [
                  /// LEFT MENU
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
                  ),
                  onPressed: () {
                    /*    Navigator.pop(
                      context,
                      AdsFilter(
                        sort: priceSort == "low"
                            ? "price_low_to_high"
                            : "price_high_to_low",
                        district: selectedDistrict,
                        taluk: selectedTaluk,
                        panchayat: selectedPanchayat,
                        village: selectedVillage,
                      ),
                    );*/
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

  /// LEFT MENU ITEM
  Widget _leftItem(String title, int index) {
    final selected = selectedTab == index;

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

  /// RIGHT PANEL SWITCH
  Widget _buildRightView() {
    switch (selectedTab) {
      case 0:
        return _priceView();
      case 1:
        return _locationView();
      default:
        return const SizedBox();
    }
  }

  /// PRICE VIEW
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
        border: Border.all(),
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

  /// LOCATION VIEW
  Widget _locationView() {
    return Consumer<UserProvider>(
      builder: (context, userP, _) {
        final user = userP.user;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final district = (user.district ?? "").trim();
        final taluk = (user.taluk ?? "").trim();
        final panchayat = (user.panchayat ?? "").trim();
        final village = (user.village ?? "").trim();

        return ListView(
          children: [
            _checkTile(
              "DISTRICT",
              district,
              selectedDistrict,
              (v) => setState(() => selectedDistrict = v),
            ),

            _checkTile(
              "TALUK",
              taluk,
              selectedTaluk,
              (v) => setState(() => selectedTaluk = v),
            ),

            _checkTile(
              "GRAM PANCHAYAT",
              panchayat,
              selectedPanchayat,
              (v) => setState(() => selectedPanchayat = v),
            ),

            _checkTile(
              "VILLAGE",
              village,
              selectedVillage,
              (v) => setState(() => selectedVillage = v),
            ),
          ],
        );
      },
    );
  }

  Widget _checkTile(
    String label,
    String value,
    String? selectedValue,
    ValueChanged<String?> onSelect,
  ) {
    final checked = selectedValue == value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: Colors.grey.shade200,
          child: ListTile(
            title: Text(value),
            trailing: Icon(
              checked ? Icons.check_box : Icons.check_box_outline_blank,
              color: checked ? Colors.green : Colors.grey,
            ),
            onTap: () => onSelect(checked ? null : value),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
