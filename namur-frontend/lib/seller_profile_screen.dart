import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_namur_frontend/Widgets/custom_appbar.dart';
import 'package:the_namur_frontend/models/othersad_model.dart';
import 'package:the_namur_frontend/screens/seller_ads_provider.dart';

import 'Widgets/productitemcard.dart';
import 'Widgets/user_info_card.dart';
import 'models/machinery_ad_model.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<SellerAdsProvider>(context, listen: false).fetchSellerAds();
    });
  }
  Future<void> _refreshAds() async {
    await Provider.of<SellerAdsProvider>(
      context,
      listen: false,
    ).fetchSellerAds();
  }

  @override
  Widget build(BuildContext context) {
    final adsProvider = Provider.of<SellerAdsProvider>(context);
    final ads = adsProvider.sellerAds;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Seller Store",
        showBack: true,
      ),
      body: adsProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ads.isEmpty
          ? const Center(child: Text("No Ads Available"))
          : Column(
        children: [
          const SizedBox(height: 10),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: UserInfoCard(),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: RefreshIndicator(
              color: Colors.green,
              onRefresh: _refreshAds,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: ads.length,
                itemBuilder: (context, index) {
                  final item = ads[index];
                  final isMachinery =
                      item["category_name"] == "Machinery";

                  /// FETCH MACHINERY / PRODUCT AD MODEL
                  final machineryAd = isMachinery
                      ? MachineryAdModel.fromJson(item)
                      : null;

                  final productAd = !isMachinery
                      ? OtherAdModel.fromJson(item)
                      : null;

                  /// For NON-MACHINERY → Fetch breeds using productId
                  return FutureBuilder<List<String>>(
                    future: isMachinery
                        ? Future.value([]) // machinery doesn't need breeds
                        : adsProvider.fetchBreeds(item["product_id"]),
                    builder: (context, snapshot) {
                      final breeds = snapshot.data ?? [];

                      return ProductCardList(
                         machineryAd: machineryAd,
                        productAd: productAd,
                        breeds: breeds, // 💥 PASS BREEDS LIST
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(String? dateString) {
    if (dateString == null) return "Unknown";
    final date = DateTime.parse(dateString);
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return "${diff.inDays} Days Ago";
    if (diff.inHours > 0) return "${diff.inHours} Hours Ago";
    return "${diff.inMinutes} Min Ago";
  }
}
