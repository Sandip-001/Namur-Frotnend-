import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Widgets/custom_appbar.dart';
import '../Widgets/drawer_menu.dart';
import '../utils/api_url.dart';
import '../models/machinery_ad_model.dart';
import '../models/othersad_model.dart';

import 'machinery_description_screen.dart';
import 'other_description_screen.dart';
import 'home_screen.dart';

class NewAddsScreen extends StatefulWidget {
  const NewAddsScreen({super.key});

  @override
  State<NewAddsScreen> createState() => _NewAddsScreenState();
}

class _NewAddsScreenState extends State<NewAddsScreen> {

  late Future<List<dynamic>> _adsFuture;

  Future<List<dynamic>> fetchAds() async {
    final prefs = await SharedPreferences.getInstance();
    final district = prefs.getString("district");

    final url = Uri.parse(ApiConstants.activeAdsByDistrict(district!));
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('failed_load_ads'.tr());
    }
  }

  @override
  void initState() {
    super.initState();
    _adsFuture = fetchAds();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _adsFuture = fetchAds();
    });
    await _adsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: const DrawerMenu(),
      appBar: CustomAppBar(
        title: 'new_ads'.tr(),
        showBack: true,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF1E7A3F),
        onRefresh: _onRefresh,
        child: FutureBuilder(
          future: _adsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
        
            if (snapshot.hasError) {
              return Center(child: Text("${'error'.tr()}: ${snapshot.error}"));
            }
        
            final ads = snapshot.data as List;
        
            if (ads.isEmpty) {
              return Center(child: Text('no_ads_available'.tr()));
            }
        
            return Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: ads.length,
                    itemBuilder: (_, i) {
                      final ad = ads[i];

                      final imageUrl =
                      (ad["images"] != null && ad["images"].isNotEmpty)
                          ? ad["images"][0]["url"]
                          : "https://via.placeholder.com/150";

                      return GestureDetector(
                        onTap: () {
                          final category =
                              ad["category_name"]?.toString().toLowerCase() ?? "";

                          if (category == "machinery") {
                            final machineryAd =
                            MachineryAdModel.fromJson(ad);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MachineryDescriptionScreen(ad: machineryAd,isBooking: false,),
                              ),
                            );
                          } else {
                            final otherAd =
                            OtherAdModel.fromJson(ad);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    OtherDescriptionScreen(ad: otherAd),
                              ),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7F4E9),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(6),
                                child: Column(
                                  children: [
                                    Text(
                                      "${ad["price"] ?? ""} /${ad["unit"] ?? ""}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      " @ ${ad["districts"][0]}",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E7A3F),
                      minimumSize: const Size(120, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'skip'.tr(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
