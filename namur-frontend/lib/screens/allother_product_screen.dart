import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ads_filter_model.dart';
import '../models/product_model_api.dart';
import '../provider/machinery_ads_provider.dart';
import '../Widgets/OtherProductCard.dart';
import '../Widgets/custom_appbar.dart';
import '../provider/user_provider.dart';
import '../utils/api_url.dart';
import 'filter_bottom_sheet.dart';
import 'other_description_screen.dart';

class AllOtherProductsScreen extends StatefulWidget {
  final ProductModel product;

  const AllOtherProductsScreen({
    super.key,
    required this.product,
  });

  @override
  State<AllOtherProductsScreen> createState() => _AllOtherProductsScreenState();
}

class _AllOtherProductsScreenState extends State<AllOtherProductsScreen> {
  bool _adsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_adsLoaded) {
      _adsLoaded = true;
      _loadAds();
    }
  }
  Future<void> _showEnquiryDialog() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("uid"); // fetch user id

    String? selectedBreed;
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          "Send Enquiry for ${widget.product.name}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),

                      IconButton(
                        icon: const Icon(Icons.close, size: 28, color: Colors.black),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Breed dropdown
  /*                DropdownButtonFormField<String>(
                    value: selectedBreed,
                    decoration: InputDecoration(
                      labelText: "Select Breed",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    items: widget.product.breeds
                        .map((breed) => DropdownMenuItem(
                      value: breed,
                      child: Text(breed),
                    ))
                        .toList(),
                    onChanged: (value) {
                      selectedBreed = value;
                    },
                  ),

                  const SizedBox(height: 16),*/

                  // Description text field
                  TextFormField(
                    controller: descriptionController,
                    maxLines: 3,
                    maxLength: 50,
                    decoration: InputDecoration(
                      labelText: "Description",
                      hintText: "Enter your enquiry",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [

                      Expanded(
                        child: SizedBox(
                          width: 150,
                          child: ElevatedButton(

                            onPressed: () async {
                              if (descriptionController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Please fill all fields"),backgroundColor: Colors.orange,),
                                );
                                return;
                              }

                              await _sendEnquiry(
                                userId: userId ?? "6",
                                productId: widget.product.id,

                                description: descriptionController.text,
                              );

                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 3,
                            ),
                            child: const Text("Send Enquiry"),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendEnquiry({
    required String userId,
    required int productId,

    required String description,
  }) async {
    final url = Uri.parse(ApiConstants.enquiry);/// replace with your endpoint


    final body = jsonEncode({
      "user_id": userId,
      "product_id": productId,
      "breed": widget.product.breeds.first,
      "enquiry_type": "buy",
      "description": description,
    });

    try {
      final response = await http.post(
       url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
print(body);
print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enquiry sent successfully"),backgroundColor: Colors.orange,),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.body}"),backgroundColor: Colors.orange,),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"),backgroundColor: Colors.orange,),
      );
    }
  }

  Future<void> _loadAds() async {
    final prefs = await SharedPreferences.getInstance();
    String district = prefs.getString("district") ?? "";

    final provider = Provider.of<MachineryAdsProvider>(context, listen: false);

    await provider.fetchFilteredAds(
      productId: widget.product.id,
      district: district,
      adType: "sell", // Other products only have SELL
    );
  }

  void _refreshAds() async {
    await _loadAds();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MachineryAdsProvider>(context);
    final items = provider.otherAds; // Use other ads list
final filteredItems=items;
/*    final filteredItems = items.where((ad) {
      return ad.productId == widget.product.id;
    }).toList();*/

    return Scaffold(
      appBar: CustomAppBar(title: "all_products".tr(), showBack: true),
backgroundColor: Colors.white,

      floatingActionButton: filteredItems.isNotEmpty
          ? GestureDetector(
              onTap: _showEnquiryDialog,
              child: Image.asset(
                'assets/icons/support_home.png',
                width: 50,
                height: 50,
              ),
            )
          : null,
      body: Column(
        children: [
          // Top filter row (same padding as original)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.filter_alt),
                  label: const Text("Show Filter"),
                  onPressed: () {
                    _openFilterSheet(context);
                  },
                ),

                const Spacer(),


              ],
            ),
          ),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "No ads found",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20,),
                  if (filteredItems.isEmpty)
                     GestureDetector(
                       onTap: _showEnquiryDialog,
                       child: Image.asset(
                         'assets/icons/support_home.png',
                         width: 55,
                         height: 55,
                       ),
                     ),

                ],
              ),
            )
                : ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (_, i) {
                final ad = filteredItems[i];
                return OtherProductCard(
                  ad: ad,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            OtherDescriptionScreen(ad: ad),
                      ),
                    );
                    _refreshAds();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openFilterSheet(BuildContext context) async {
    final userP = context.read<UserProvider>();

    // ✅ Ensure fresh profile data is loaded before opening filter
    await userP.fetchProfile();

    final result = await showModalBottomSheet<AdsFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return FilterBottomSheet(product: widget.product);
        // or: FilterBottomSheet(product: widget.product)
      },
    );
    print('Result');
print(result);
    // ✅ Apply filter result
    if (result != null) {
      final provider =
      Provider.of<MachineryAdsProvider>(context, listen: false);

      await provider.fetchAdsWithFilterStacked(result);
    }
  }


}
