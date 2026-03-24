import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:the_namur_frontend/Widgets/custom_appbar.dart';
import 'package:the_namur_frontend/Widgets/drawer_menu.dart';
import 'package:the_namur_frontend/Widgets/productitemcard.dart';
import '../models/product_model_api.dart';
import '../provider/product_ads_provider.dart';
import 'machine_details_screen.dart';
import 'product_details_screen.dart';

// ---------------- Sort & Filter Widget ----------------
class SortFilterWidget extends StatelessWidget {
  final String selectedSort;
  final List<String> selectedBreeds;
  final Function(String) onSortSelected;
  final Function(List<String>) onBreedsChanged;
  final VoidCallback onApply;
  final List<String> allBreeds;
  final bool showSortOptions;
  final bool showFilterOptions;
  final VoidCallback toggleSort;
  final VoidCallback toggleFilter;

  const SortFilterWidget({
    super.key,
    required this.selectedSort,
    required this.selectedBreeds,
    required this.onSortSelected,
    required this.onBreedsChanged,
    required this.onApply,
    required this.allBreeds,
    required this.showSortOptions,
    required this.showFilterOptions,
    required this.toggleSort,
    required this.toggleFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---------------- BUTTON ROW ----------------
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: toggleSort, child: const Text("Sort By")),
            ElevatedButton(
              onPressed: toggleFilter,
              child: const Text("Filter"),
            ),
            ElevatedButton(onPressed: onApply, child: const Text("Apply")),
          ],
        ),
        const SizedBox(height: 8),

        // ---------------- SORT OPTIONS ----------------
        if (showSortOptions)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Wrap(
              spacing: 12,
              children: [
                ChoiceChip(
                  label: const Text("Low → High"),
                  selected: selectedSort == "Low to High",
                  onSelected: (_) => onSortSelected("Low to High"),
                ),
                ChoiceChip(
                  label: const Text("High → Low"),
                  selected: selectedSort == "High to Low",
                  onSelected: (_) => onSortSelected("High to Low"),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),

        // ---------------- FILTER OPTIONS ----------------
        if (showFilterOptions)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Select Category",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Wrap(
                  spacing: 6,
                  runSpacing: 0,
                  children: allBreeds.map((breed) {
                    return FilterChip(
                      label: Text(breed, style: const TextStyle(fontSize: 14)),
                      selected: selectedBreeds.contains(breed),
                      onSelected: (selected) {
                        final newList = List<String>.from(selectedBreeds);
                        if (selected) {
                          newList.add(breed);
                        } else {
                          newList.remove(breed);
                        }
                        onBreedsChanged(newList);
                      },
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => onBreedsChanged([]),
                      child: const Text(
                        "Clear",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------- ProductInventoryScreen ----------------
class ProductInventoryScreen extends StatefulWidget {
  final ProductModel selectedProduct;

  const ProductInventoryScreen({super.key, required this.selectedProduct});

  @override
  State<ProductInventoryScreen> createState() => _ProductInventoryScreenState();
}

class _ProductInventoryScreenState extends State<ProductInventoryScreen> {
  String sortBy = "None";
  List<String> filterBreeds = [];
  bool showSortOptions = false;
  bool showFilterOptions = false;

  @override
  Widget build(BuildContext context) {
    final adsProvider = Provider.of<ProductAdsProvider>(context);
    final adsList = adsProvider.ads;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: tr("product_inventory.title")),
      drawer: const DrawerMenu(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
        onPressed: () {
          String parentType = widget.selectedProduct.categoryName ?? "";
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  openScreen(parentType, false, widget.selectedProduct),
            ),
          );
        },
      ),
      body: adsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : adsList.isEmpty
          ? Center(child: Text(tr("product_inventory.no_inventory_found")))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  /*   SortFilterWidget(
              selectedSort: sortBy,
              selectedBreeds: filterBreeds,
              allBreeds: widget.selectedProduct.breeds ?? [],
              showSortOptions: showSortOptions,
              showFilterOptions: showFilterOptions,
              toggleSort: () => setState(() {
                showSortOptions = !showSortOptions;
              }),
              toggleFilter: () => setState(() {
                showFilterOptions = !showFilterOptions;
              }),
              onSortSelected: (value) => setState(() {
                sortBy = value;
              }),
              onBreedsChanged: (list) => setState(() {
                filterBreeds = list;
              }),
              onApply: () async {
                await adsProvider.fetchAds(
                  productId: widget.selectedProduct.id,
                  district: "",
                  sort: sortBy == "Low to High"
                      ? "price_low_to_high"
                      : sortBy == "High to Low"
                      ? "price_high_to_low"
                      : null,
                  breeds: filterBreeds,
                );
              },
            ),*/
                  const SizedBox(height: 12),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: adsList.length,
                    itemBuilder: (context, index) {
                      final ad = adsList[index];
                      return ProductCardList(
                        machineryAd: null,
                        productAd: ad,
                        breeds: widget.selectedProduct.breeds,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget openScreen(String parentType, bool isBuy, product) {
    switch (parentType.toLowerCase()) {
      case "animal":
        return ProductDetailsScreen(
          selectedProduct: product,
          screenTitle: tr("product_inventory.animal_details"),
        );
      case "food":
        return ProductDetailsScreen(
          selectedProduct: product,
          screenTitle: tr("product_inventory.crop_details"),
        );
      case "machinery":
        return MachineDetailsScreen(selectedProduct: product);
      default:
        return MachineDetailsScreen(selectedProduct: product);
    }
  }
}
