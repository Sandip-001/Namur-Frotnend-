import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ads_filter_model.dart';
import '../models/product_model_api.dart';
import '../provider/user_provider.dart';

class FilterBottomSheet extends StatefulWidget {
  final ProductModel product;

  const FilterBottomSheet({super.key, required this.product});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  int selectedTab = 0; // 0=Price,1=Categories,2=Locations

  String priceSort = "low";
  final Set<String> selectedCategories = {};
  String? selectedCondition;
  String? selectedDistrict;
  String? selectedTaluk;
  String? selectedPanchayat;
  String? selectedVillage;

  bool get isMachinery =>
      widget.product.categoryName.toLowerCase() == "machinery";

  @override
  void initState() {
    super.initState();

    /*  if (isMachinery) {
      selectedCondition = "new"; // ✅ makes "New" selected by default
    }*/
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userP = context.read<UserProvider>();

      if (userP.user == null) {
        await userP.fetchProfile(); // or loadUser()
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.95,
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
                    onPressed: () {
                      Navigator.pop(
                        context,
                        AdsFilter(
                          productId: widget.product.id,
                          sort: priceSort == "low"
                              ? "price_low_to_high"
                              : "price_high_to_low",
                          district: selectedDistrict,
                          taluk: selectedTaluk,
                          village: selectedVillage,
                          panchayat: selectedPanchayat,
                          breeds: selectedCategories.toList(),
                          machineCondition: isMachinery
                              ? selectedCondition
                              : null,
                        ),
                      );
                    },

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

                        if (isMachinery) _leftItem("Condition", 3),

                        /// ⛔ Hide Categories if machinery
                        if (!isMachinery) _leftItem("Categories", 1),

                        _leftItem("Locations", 2),
                      ],
                    ),
                  ),

                  /// RIGHT CONTENT
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
                width: MediaQuery.of(context).size.width * 0.5,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      AdsFilter(
                        productId: widget.product.id,
                        sort: priceSort == "low"
                            ? "price_low_to_high"
                            : "price_high_to_low",
                        district: selectedDistrict,
                        taluk: selectedTaluk,
                        village: selectedVillage,
                        panchayat: selectedPanchayat,
                        breeds: selectedCategories.toList(),
                        machineCondition: isMachinery
                            ? selectedCondition
                            : null,
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

  /// LEFT MENU ITEM
  Widget _leftItem(String title, int index) {
    final bool selected = selectedTab == index;

    return InkWell(
      onTap: () {
        /// ⛔ Prevent opening Categories tab for machinery
        if (isMachinery && index == 1) return;

        setState(() => selectedTab = index);
      },
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
        return isMachinery ? const SizedBox() : _categoryView();
      case 2:
        return _locationView();
      case 3:
        return !isMachinery ? const SizedBox() : _conditionView(); // ✅ new
      default:
        return const SizedBox();
    }
  }

  Widget _conditionView() {
    return Column(
      children: [
        _conditionRadioTile("Used", "used"),
        _conditionRadioTile("New", "new"),
      ],
    );
  }

  Widget _conditionRadioTile(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: selectedCondition,
        activeColor: Colors.green,
        title: Text(title),
        onChanged: (v) => setState(() => selectedCondition = v),
      ),
    );
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

  /// CATEGORY VIEW
  Widget _categoryView() {
    final breeds = widget.product.breeds;

    if (breeds.isEmpty) {
      return const Center(child: Text("No breeds available"));
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: breeds.map((breed) {
        final selected = selectedCategories.contains(breed);
        return _checkTile(breed, selected, () {
          setState(() {
            selected
                ? selectedCategories.remove(breed)
                : selectedCategories.add(breed);
          });
        });
      }).toList(),
    );
  }

  /// LOCATION VIEW
  Widget _locationView() {
    return Consumer<UserProvider>(
      builder: (context, userP, _) {
        final user = userP.user;
        debugPrint("USER IN FILTER: $user");

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final district = (user.district ?? "").trim();
        final taluk = (user.taluk ?? "").trim();
        final panchayat = (user.panchayat ?? "").trim();
        final village = (user.village ?? "").trim();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// DISTRICT
            _checkLocationTile(
              "DISTRICT",
              district,
              selectedDistrict == district,
              () {
                setState(() {
                  selectedDistrict = selectedDistrict == district
                      ? null
                      : district;
                });
              },
            ),
            const SizedBox(height: 12),

            /// TALUK
            _checkLocationTile("TALUK", taluk, selectedTaluk == taluk, () {
              setState(() {
                selectedTaluk = selectedTaluk == taluk ? null : taluk;
              });
            }),
            const SizedBox(height: 12),

            /// PANCHAYAT
            _checkLocationTile(
              "GRAM PANCHAYAT",
              panchayat,
              selectedPanchayat == panchayat,
              () {
                setState(() {
                  selectedPanchayat = selectedPanchayat == panchayat
                      ? null
                      : panchayat;
                });
              },
            ),
            const SizedBox(height: 12),

            /// VILLAGE
            _checkLocationTile(
              "VILLAGE",
              village,
              selectedVillage == village,
              () {
                setState(() {
                  selectedVillage = selectedVillage == village ? null : village;
                });
              },
            ),
          ],
        );
      },
    );
  }

  /// COMMON CHECK TILE
  Widget _checkTile(String title, bool checked, VoidCallback onTap) {
    if (title.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: Colors.grey.shade200,
      child: ListTile(
        title: Text(title),
        trailing: Icon(
          checked ? Icons.check_box : Icons.check_box_outline_blank,
          color: checked ? Colors.green : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _checkLocationTile(
    String label,
    String value,
    bool checked,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
          height: 48,
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: Colors.grey.shade200,
          child: ListTile(
            dense: true,
            title: Text(value.isEmpty ? "Not set" : value),
            trailing: value.isEmpty
                ? null
                : Icon(
                    checked ? Icons.check_box : Icons.check_box_outline_blank,
                    color: checked ? Colors.green : Colors.grey,
                  ),
            onTap: value.isEmpty ? null : onTap,
          ),
        ),
      ],
    );
  }
}
