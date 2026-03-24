import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_url.dart';

class SellerAdsProvider with ChangeNotifier {
  bool isLoading = false;
  List<dynamic> sellerAds = [];

  /// Cache for breeds → avoids calling API repeatedly
  Map<int, List<String>> cachedBreeds = {};

  // ----------------------------------------------------------------------
  // FETCH SELLER ADS
  // ----------------------------------------------------------------------
  Future<void> fetchSellerAds() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("uid");
    if (userId == null) return;

    try {
      isLoading = true;
      notifyListeners();

      final url = Uri.parse(
          "${ApiConstants.baseUrl}/ads/filter?userType=user&userId=$userId&status=active");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        sellerAds = jsonDecode(response.body);
      } else {
        sellerAds = [];
      }
    } catch (e) {
      sellerAds = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // ----------------------------------------------------------------------
  // FETCH BREEDS FOR A PRODUCT
  // API: https://namur-backend-f09v.onrender.com/api/products/<productId>
  // ----------------------------------------------------------------------
  Future<List<String>> fetchBreeds(int productId) async {
    try {
      /// Already fetched? return cached list
      if (cachedBreeds.containsKey(productId)) {
        return cachedBreeds[productId]!;
      }

      final url = Uri.parse(ApiConstants.productDetails(productId));


      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        List<String> breeds =
        List<String>.from(data["data"]["breeds"] ?? []);

        cachedBreeds[productId] = breeds; // STORE IN CACHE
        return breeds;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
