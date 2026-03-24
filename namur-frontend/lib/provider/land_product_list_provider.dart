import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_url.dart';

class LandProductItem {
  final int id;
  final String category;
  final String productName;
  final String imageUrl;

  LandProductItem({
    required this.id,
    required this.category,
    required this.productName,
    required this.imageUrl,
  });

  factory LandProductItem.fromJson(Map<String, dynamic> json) {
    return LandProductItem(
      id: json["id"],                       // 👈 REQUIRED for delete
      category: json["category"],
      productName: json["product_name"],
      imageUrl: json["product_image_url"],
    );
  }
}

class LandProductListProvider extends ChangeNotifier {
  bool isLoading = false;
  List<LandProductItem> items = [];


  // Old method for other screens
  Future<void> fetchLandProducts(int landId) async {
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
      final url = Uri.parse(ApiConstants.landProducts(int.parse(userId), landId));

      final response = await http.get(url);
      print('land products');

      print(response.body);

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        items = decoded.map((e) => LandProductItem.fromJson(e)).toList();
      } else {
        items = [];
      }
    } catch (e) {
      print("Land Product Fetch Error: $e");
      items = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // ---------------- NEW METHOD: fetch by category for MoreDetailsScreen ----------------
  bool isCategoryLoading = false;
  List<LandProductItem> foodItems = [];
  List<LandProductItem> machineryItems = [];
  List<LandProductItem> animalItems = [];

  Future<void> fetchLandProductsByCategory(String category) async {
    try {
      isCategoryLoading = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("uid");

      if (userId == null) {
        isCategoryLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse(ApiConstants.landProductsByCategory(int.parse(userId), category));

      final response = await http.get(url);
      print("category fetch");
      print(response.statusCode);

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        final List<LandProductItem> fetchedItems =
        decoded.map((e) => LandProductItem.fromJson(e)).toList();

        switch (category.toLowerCase()) {
          case "food":
            foodItems = fetchedItems;
            break;
          case "machinery":
            machineryItems = fetchedItems;
            break;
          case "animal":
            animalItems = fetchedItems;
            break;
        }
      } else {
        switch (category.toLowerCase()) {
          case "food":
            foodItems = [];
            break;
          case "machinery":
            machineryItems = [];
            break;
          case "animal":
            animalItems = [];
            break;
        }
      }
    } catch (e) {
      print("Land Product Fetch by Category Error: $e");
      switch (category.toLowerCase()) {
        case "food":
          foodItems = [];
          break;
        case "machinery":
          machineryItems = [];
          break;
        case "animal":
          animalItems = [];
          break;
      }
    }

    isCategoryLoading = false;
    notifyListeners();
  }

  // Getter for old functionality
  List<LandProductItem> get food => items.where((e) => e.category == "Food").toList();
  List<LandProductItem> get machinery =>
      items.where((e) => e.category == "Machinery").toList();
  List<LandProductItem> get animal =>
      items.where((e) => e.category == "Animal").toList();


  //method to fetch userid/landid?category in land detail screen

// ADD NEW LISTS FOR NEW API (PER LAND)
  List<LandProductItem> landFoodItems = [];
  List<LandProductItem> landMachineryItems = [];
  List<LandProductItem> landAnimalItems = [];

  bool isNewCategoryLoading = false;

// ---------------- NEW METHOD FOR MoreDetailsScreen ----------------
  Future<void> fetchLandProductsByCategoryForLand({
    required int landId,
    required String category,
  }) async {
    try {
      isNewCategoryLoading = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("uid");

      if (userId == null) {
        isNewCategoryLoading = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse(
        ApiConstants.landProductsByCategoryForLand(userId, landId, category),
      );

      final response = await http.get(url);
      print("NEW category fetch URL: $url");
      print("STATUS: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        final List<LandProductItem> fetchedItems =
        decoded.map((e) => LandProductItem.fromJson(e)).toList();

        switch (category.toLowerCase()) {
          case "food":
            landFoodItems = fetchedItems;
            break;
          case "machinery":
            landMachineryItems = fetchedItems;
            break;
          case "animal":
            landAnimalItems = fetchedItems;
            break;
        }
      } else {
        switch (category.toLowerCase()) {
          case "food":
            landFoodItems = [];
            break;
          case "machinery":
            landMachineryItems = [];
            break;
          case "animal":
            landAnimalItems = [];
            break;
        }
      }
    } catch (e) {
      print("NEW Land Product Fetch by Category Error: $e");

      switch (category.toLowerCase()) {
        case "food":
          landFoodItems = [];
          break;
        case "machinery":
          landMachineryItems = [];
          break;
        case "animal":
          landAnimalItems = [];
          break;
      }
    }

    isNewCategoryLoading = false;
    notifyListeners();
  }

  Future<bool> deleteLandProduct(int productId) async {
    try {
      final url = Uri.parse(
        ApiConstants.deleteLandProduct(productId),
      );

      final response = await http.delete(url);
      print("Delete API Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Remove from all lists where it may exist
        landFoodItems.removeWhere((item) => item.id == productId);
        landMachineryItems.removeWhere((item) => item.id == productId);
        landAnimalItems.removeWhere((item) => item.id == productId);

        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Delete Error: $e");
    }
    return false;
  }


}
