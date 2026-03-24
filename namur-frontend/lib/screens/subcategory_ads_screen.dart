import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Widgets/OtherProductCard.dart';
import '../Widgets/custom_appbar.dart';

import '../provider/subcategory_ads_provider4.dart';
import '../utils/api_url.dart';
import 'other_description_screen.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import '../models/ads_filter_model.dart';
import 'subcategory_filter_bottom_sheet.dart';

class SubCategoryAdsScreen extends StatefulWidget {
  final String subcategory;

  const SubCategoryAdsScreen({super.key, required this.subcategory});

  @override
  State<SubCategoryAdsScreen> createState() => _SubCategoryAdsScreenState();
}

class _SubCategoryAdsScreenState extends State<SubCategoryAdsScreen> {
  @override
  void initState() {
    super.initState();
  }

  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_loaded) {
      _loaded = true;

      context.read<SubCategoryAdsProvider>().fetchAdsBySubCategory(
        subCategory: widget.subcategory,
      );
    }
  }

  Future<void> _showEnquiryDialog() async {
    final prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("uid");

    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Send Enquiry",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () async {
                    if (descriptionController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter description"),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    await _sendEnquiry(
                      userId: userId,
                      description: descriptionController.text,
                    );

                    Navigator.pop(context);
                  },
                  child: const Text("Send Enquiry"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendEnquiry({
    required String? userId,
    required String description,
  }) async {
    final url = Uri.parse(ApiConstants.enquiry);

    final body = jsonEncode({
      "user_id": userId,
      "subcategory": widget.subcategory,
      "enquiry_type": "buy",
      "description": description,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enquiry sent successfully"),
          backgroundColor: Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed: ${response.body}"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SubCategoryAdsProvider>();
    final ads = provider.ads;
    final isLoading = provider.isLoading;

    return Scaffold(
      appBar: CustomAppBar(title: widget.subcategory, showBack: true),

      /// ✅ FAB only if ads exist
      floatingActionButton: ads.isNotEmpty
          ? GestureDetector(
              onTap: _showEnquiryDialog,
              child: Image.asset(
                'assets/icons/support_home.png',
                width: 55,
                height: 55,
              ),
            )
          : null,

      body: Column(
        children: [
          /// ✅ FILTER BUTTON
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
                  onPressed: () => _openFilterSheet(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ads.isEmpty
                ? _emptyState()
                : ListView.builder(
                    itemCount: ads.length,
                    itemBuilder: (_, index) {
                      final ad = ads[index];
                      return OtherProductCard(
                        ad: ad,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OtherDescriptionScreen(ad: ad),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("No ads found"),
          const SizedBox(height: 20),
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
    );
  }

  void _openFilterSheet(BuildContext context) async {
    final userP = context.read<UserProvider>();

    if (userP.user == null) {
      await userP.loadUser();
    }

    final result = await showModalBottomSheet<AdsFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) =>
          SubCategoryFilterBottomSheet(subcategory: widget.subcategory),
    );

    if (result != null) {
      await context.read<SubCategoryAdsProvider>().fetchAdsWithFilterStacked(
        result,
        subcategoryName: widget.subcategory,
      );
    }
  }
}
