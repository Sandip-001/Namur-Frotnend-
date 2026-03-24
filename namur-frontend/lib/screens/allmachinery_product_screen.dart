import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Widgets/machinert_product_card.dart';
import '../models/ads_filter_model.dart';
import '../models/product_model_api.dart';
import '../provider/machinery_ads_provider.dart';
import '../provider/user_provider.dart';
import '../utils/api_url.dart';
import 'filter_bottom_sheet.dart';
import 'machinery_description_screen.dart';
import '../Widgets/custom_appbar.dart';
import '../Widgets/three_way_toggle.dart';

class AllMachineryProductsScreen extends StatefulWidget {
  final ProductModel productId;
  final String filterType;

  const AllMachineryProductsScreen({
    super.key,
    required this.productId,
    required this.filterType,
  });

  @override
  State<AllMachineryProductsScreen> createState() =>
      _AllMachineryProductsScreenState();
}

class _AllMachineryProductsScreenState
    extends State<AllMachineryProductsScreen> {
  late String listFilter;
  bool _adsLoaded = false;

  @override
  void initState() {
    print('all machinery product');
    // TODO: implement initState
    listFilter = widget.filterType;
    super.initState();
  }

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
    String? userId = prefs.getString("uid");
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      barrierDismissible: false, // prevents accidental dismiss
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                          "Send Enquiry for ${widget.productId.name}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 28,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description field
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () async {
                      if (descriptionController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter a description"),
                          ),
                        );
                        return;
                      }

                      // Send enquiry
                      await _sendEnquiry(
                        userId: userId,
                        productId: widget.productId.id,
                        breed: "", // machinery does not need breed
                        enquiryType: "rent", // default type
                        description: descriptionController.text,
                      );

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Send Enquiry"),
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
    required String? userId,
    required int productId,
    required String breed, // can be empty for machinery
    required String enquiryType,
    required String description,
  }) async {
    final url = Uri.parse(ApiConstants.enquiry);
    print("enquiry URL =>$url");

    /// replace with your endpoint

    final body = jsonEncode({
      "user_id": userId,
      "product_id": productId,
      // empty string for machinery
      "enquiry_type": enquiryType,
      "description": description,
    });
    print(body);
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enquiry sent successfully")),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _loadAds() async {
    final prefs = await SharedPreferences.getInstance();
    // 🧪 TEST: hardcoded district for testing — revert after done
    String district = prefs.getString("district") ?? "Belgaum";

    final provider = Provider.of<MachineryAdsProvider>(context, listen: false);

    String adTypeToSend = listFilter;

    await provider.fetchFilteredAds(
      productId: widget.productId.id,
      district: district,
      adType: adTypeToSend,
    );
  }

  void _refreshAds() async {
    await _loadAds();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MachineryAdsProvider>(context);
    final items = provider.machineryAds;
    final filteredItems = items;
    /*    // Filter ads for this productId only
    final filteredItems = items.where((ad) {
      return ad.productId == widget.productId.id;
    }).toList();*/

    return Scaffold(
      appBar: CustomAppBar(title: "all_products".tr(), showBack: true),
      backgroundColor: Colors.white,
      floatingActionButton: filteredItems.isNotEmpty
          ? GestureDetector(
              onTap: _showEnquiryDialog,
              child: Image.asset(
                'assets/icons/support_home.png',
                width: 55,
                height: 55,
              ),
            )
          : null,
      // Floating button logic same as old
      body: Column(
        children: [
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

                Row(
                  children: [
                    ThreeWayToggle(
                      selectedValue: listFilter,
                      onChanged: (v) {
                        setState(() {
                          listFilter = v;
                        });
                        _refreshAds();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "No ads found",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 20),
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
                  )
                : ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (_, i) {
                      final ad = filteredItems[i];
                      return MachineryAdCard(
                        ad: ad,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MachineryDescriptionScreen(
                                ad: ad,
                                isBooking: false,
                              ),
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
        return FilterBottomSheet(product: widget.productId);
        // or: FilterBottomSheet(product: widget.product)
      },
    );
    print(result);
    // ✅ Apply filter result
    if (result != null) {
      final provider = Provider.of<MachineryAdsProvider>(
        context,
        listen: false,
      );

      await provider.fetchAdsWithFilterStacked(
        result,

        //   adType: isRent ? "rent" : "sell",
      );
    }
  }

  Future<void> _applyFilter(Map<String, dynamic> filter) async {
    final provider = Provider.of<MachineryAdsProvider>(context, listen: false);

    await provider.fetchAdsWithSortFilter(
      productId: widget.productId.id,
      district: filter["district"],
      taluk: filter["taluk"],
      village: filter["village"],
      panchayat: filter["panchayat"],
      sort: filter["sort"],
      breeds: filter["breeds"],
      adType: listFilter,
    );
  }
}
