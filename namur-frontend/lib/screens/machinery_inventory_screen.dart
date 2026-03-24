import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Widgets/custom_appbar.dart';
import '../Widgets/drawer_menu.dart';
import '../Widgets/productitemcard.dart';
import '../provider/machinery_ads_provider.dart';
import '../models/product_model_api.dart';
import 'machine_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Widgets/three_way_toggle.dart';

class MachineryInventoryScreen extends StatefulWidget {
  final ProductModel selectedProduct;
  final String filterType;

  const MachineryInventoryScreen({
    super.key,
    required this.selectedProduct,
    required this.filterType,
  });

  @override
  State<MachineryInventoryScreen> createState() =>
      _MachineryInventoryScreenState();
}

class _MachineryInventoryScreenState extends State<MachineryInventoryScreen> {
  String? selectedSort; // price_low_to_high / price_high_to_low
  late String listFilter;

  @override
  void initState() {
    super.initState();
    listFilter = widget.filterType;
    print(listFilter);
    _fetchAds(); // ✅ initial load
  }

  Future<void> _fetchAds() async {
    final prefs = await SharedPreferences.getInstance();
    final district = prefs.getString("district") ?? "";
    print("Dist $district");
    final provider = Provider.of<MachineryAdsProvider>(context, listen: false);

    final adTypeToSend = listFilter;
    print('selected sort $selectedSort');
    try {
      if (selectedSort == null) {
        await provider.fetchFilteredAds(
          productId: widget.selectedProduct.id,
          district: district,
          adType: adTypeToSend,
        );
      } else {
        await provider.fetchSortedAds(
          productId: widget.selectedProduct.id,
          district: district,
          sortType: selectedSort!,
          adType: adTypeToSend,
        );
      }
    } catch (e) {
      debugPrint("Fetch ads error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MachineryAdsProvider>(context);
    final adsList = provider.machineryAds;
    print("adslist");
    print(adsList);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'machinery_inventory'.tr()),
      drawer: DrawerMenu(),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  MachineDetailsScreen(selectedProduct: widget.selectedProduct),
            ),
          );
        },
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// RENT / SELL SWITCH
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ThreeWayToggle(
                  selectedValue: listFilter,
                  onChanged: (v) {
                    setState(() {
                      listFilter = v;
                      selectedSort = null;
                    });
                    _fetchAds();
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// SORT BY
            /*     Row(
              children: [
                const Text(
                  "Sort By:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),

                ChoiceChip(
                  label: const Text("Low → High"),
                  selected: selectedSort == "price_low_to_high",
                  onSelected: (selected) {
                    setState(() {
                      selectedSort =
                      selected ? "price_low_to_high" : null;
                    });
                    _fetchAds();
                  },
                ),

                const SizedBox(width: 10),

                ChoiceChip(
                  label: const Text("High → Low"),
                  selected: selectedSort == "price_high_to_low",
                  onSelected: (selected) {
                    setState(() {
                      selectedSort =
                      selected ? "price_high_to_low" : null;
                    });
                    print(selectedSort);
                    _fetchAds();
                  },
                ),
              ],
            ),*/
            const SizedBox(height: 16),

            /// ADS LIST
            if (provider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (adsList.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text("no_inventory_found".tr()),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: adsList.length,
                itemBuilder: (_, index) {
                  return ProductCardList(
                    machineryAd: adsList[index],
                    productAd: null,
                    breeds: null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
