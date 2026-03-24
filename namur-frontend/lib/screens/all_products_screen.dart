/*
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:the_namur_frontend/Widgets/machinert_product_card.dart';
import 'package:the_namur_frontend/models/product_model_api.dart';
import 'package:the_namur_frontend/provider/machinery_ads_provider.dart';

import '../Widgets/OtherProductCard.dart';
import '../Widgets/custom_appbar.dart';
import 'description_screen.dart';

class AllProductsScreen extends StatefulWidget {
  final ProductModel productId;

  const AllProductsScreen({
    super.key,
    required this.productId,
  });

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  bool isRent = true;
  bool _adsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_adsLoaded) {
      _adsLoaded = true;
      _loadAds();
    }
  }

  Future<void> _loadAds() async {
    final prefs = await SharedPreferences.getInstance();
    String district = prefs.getString("district") ?? "";

    String adTypeToSend;
    if (widget.productId.categoryName.toLowerCase() == "machinery") {
      adTypeToSend = isRent ? "rent" : "sell";
    } else {
      adTypeToSend = "sell";
    }

    final provider =
    Provider.of<MachineryAdsProvider>(context, listen: false);

    // Fetch filtered ads without clearing unnecessarily
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
    final items = provider.ads;

    final String screenCategory =
    widget.productId.categoryName.toLowerCase();

    // Null-safe filtering
    final filteredItems = items.where((ad) {
      return ad.productId == widget.productId.id &&
          (ad.categoryName?.toLowerCase() ?? "") == screenCategory;
    }).toList();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'all_products'.tr(),
        showBack: true,
      ),

      floatingActionButton: filteredItems.isEmpty
          ? GestureDetector(
              onTap: () {},
              child: Image.asset(
                'assets/icons/support_home.png',
                width: 55,
                height: 55,
              ),
            )
          : null,

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
           */
/*     ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.filter_list, color: Colors.black54),
                  label: Text("show_filters".tr()),
                ),*//*

                const Spacer(),
                if (screenCategory == "machinery")
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],
                    ),
                    child: Row(
                      children: [
                        Text('rent'.tr()),
                        Switch(
                          value: !isRent,
                          activeColor: Colors.green,
                          onChanged: (v) {
                            setState(() => isRent = !v);
                            _refreshAds();
                          },
                        ),
                        Text('sell'.tr()),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredItems.isEmpty
                ? Center(
              child: Text(
                "no_ads_found".tr(),
                style: const TextStyle(fontSize: 16),
              ),
            )
                : ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (c, i) {
                final ad = filteredItems[i];

                if (screenCategory == 'machinery') {
                  return MachineryAdCard(
                    ad: ad,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DescriptionScreen(
                              productId: ad.productId.toString()),
                        ),
                      );
                      // Refresh ads after coming back to ensure categoryName is intact
                      _refreshAds();
                    },
                  );
                } else {
                  return OtherProductCard(
                    ad: ad,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DescriptionScreen(
                              productId: ad.productId.toString()),
                        ),
                      );
                      _refreshAds();
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
*/
