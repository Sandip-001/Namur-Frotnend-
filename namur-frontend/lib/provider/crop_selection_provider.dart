import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_url.dart';
class CropSelectionProvider with ChangeNotifier {
  String? selectedLand;
  String? selectedCrop;
  int? selectedCropId;
  String? plantingDate;
  String? areaQty;

  bool isLoading = false;

  List<LandProductItem> cropList = [];

  bool get isFormComplete =>
      selectedLand != null &&
          selectedCrop != null &&
          plantingDate != null &&
          areaQty != null &&
          areaQty!.isNotEmpty;

  void setLand(String land) {
    selectedLand = land;
    notifyListeners();
  }

  void setCrop(String cropName) {
    selectedCrop = cropName;

    final crop = cropList.firstWhere(
          (c) => c.productName == cropName,
      orElse: () => LandProductItem(productId: 0, category: '', productName: '', imageUrl: ''),
    );

    print("Selected Product ID => ${crop.productId}");

    selectedCropId = crop.productId;
    notifyListeners();
  }


  void setDate(String date) {
    plantingDate = date;
    notifyListeners();
  }

  void setArea(String area) {
    areaQty = area;
    notifyListeners();
  }

  Future<void> fetchCropList({
    required int landId,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("uid");

      if (userId == null) {
        isLoading = false;
        notifyListeners();
        return;
      }

      // API call for category = food
      final url = Uri.parse(
        ApiConstants.landProductsByCategoryForLand(userId, landId, "food"),
      );

      final response = await http.get(url);
      print("Crop Fetch URL => $url");
      print("STATUS => ${response.statusCode}");

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);

        cropList =
            decoded.map((e) => LandProductItem.fromJson(e)).toList();
      } else {
        cropList = [];
      }
    } catch (e) {
      cropList = [];
      print("Crop Fetch Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
  void resetForm() {
    selectedLand = null;
    selectedCrop = null;
    selectedCropId = null;
    plantingDate = null;
    areaQty = null;
    cropList = [];

    isLoading = false;

    notifyListeners();
  }

}

class LandProductItem {
  final int productId;
  final String category;
  final String productName;
  final String imageUrl;

  LandProductItem({
    required this.productId,
    required this.category,
    required this.productName,
    required this.imageUrl,
  });

  factory LandProductItem.fromJson(Map<String, dynamic> json) {
    return LandProductItem(
      productId: json["product_id"],   // <-- use product_id
      category: json["category"],
      productName: json["product_name"],
      imageUrl: json["product_image_url"],
    );
  }
}

