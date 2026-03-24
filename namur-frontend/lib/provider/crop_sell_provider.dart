import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_namur_frontend/utils/api_url.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CropSellProvider with ChangeNotifier {
  bool isLoading = false;
  String? selectedBreed;
  List<String> breedOptions = [];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isSyncingOfflineAds = false;

  CropSellProvider() {
    _setupConnectivitySync();
  }

  bool _hasInternet(List<ConnectivityResult> results) {
    return results.any((result) => result != ConnectivityResult.none);
  }

  Future<void> _setupConnectivitySync() async {
    final initial = await Connectivity().checkConnectivity();
    if (_hasInternet(initial)) {
      await tryUploadOfflineAds();
    }

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) async {
      if (_hasInternet(results)) {
        await tryUploadOfflineAds();
      }
    });
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void setBreedsFromProduct(List<String> breeds) {
    breedOptions = breeds;
    selectedBreed = null;
    notifyListeners();
  }

  void setBreed(String val) {
    selectedBreed = val;
    notifyListeners();
  }

  // ------------------------------
  // SAVE OFFLINE AD (HIVE)
  // ------------------------------
  Future<void> saveOfflineAd(Map<String, dynamic> ad) async {
    final box = await Hive.openBox("pending_crop_ads");
    await box.add(ad);
    print("💾 Saved offline: ${ad['title']}");
  }

  // ------------------------------
  // TRY UPLOADING OFFLINE ADS
  // ------------------------------
  Future<void> tryUploadOfflineAds() async {
    if (_isSyncingOfflineAds) return;
    _isSyncingOfflineAds = true;

    final box = await Hive.openBox("pending_crop_ads");
    if (box.isEmpty) {
      _isSyncingOfflineAds = false;
      return;
    }

    print("📡 Trying to upload offline crop ads…");

    final keys = box.keys.toList();

    for (final key in keys) {
      final raw = box.get(key);
      if (raw is! Map) continue;

      Map<String, dynamic> ad = Map<String, dynamic>.from(raw);

      final images = (ad["images"] as List?) ?? [];
      final hasAllImages = images.every(
        (path) => path is String && File(path).existsSync(),
      );
      if (!hasAllImages) {
        print("⚠️ Missing image file(s), skipping offline ad: ${ad["title"]}");
        continue;
      }

      final response = await createAdFromMap(ad);
      final status = response["status"] ?? 0;

      if (status == 200 || status == 201) {
        print("✔ Uploaded offline crop ad: ${ad["title"]}");
        await box.delete(key);
      } else {
        print("❌ Failed again, keeping offline. Error: ${response["body"]}");
      }
    }

    _isSyncingOfflineAds = false;
  }

  // ------------------------------
  // Create ad from Map (offline upload)
  // ------------------------------
  Future<Map<String, dynamic>> createAdFromMap(Map<String, dynamic> ad) async {
    List<File> images = [];
    if (ad["images"] != null) {
      for (String path in ad["images"]) {
        images.add(File(path));
      }
    }

    return await createAd(
      title: ad["title"],
      categoryId: ad["categoryId"],
      subCategoryId: ad["subCategoryId"],
      productId: ad["productId"],
      productName: ad["productName"],
      quantity: ad["quantity"],
      unit: ad["unit"],
      price: ad["price"],
      description: ad["description"],
      breed: ad["breed"] ?? "",
      images: images,
    );
  }

  // ------------------------------
  // MAIN API CALL
  // ------------------------------
  Future<Map<String, dynamic>> createAd({
    required String title,
    required String categoryId,
    required String subCategoryId,
    required String productId,
    required String productName,
    required String quantity,
    required String unit,
    required String price,
    required String description,
    required String breed,
    required List<File> images,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final district = prefs.getString("district");
      final creatorId = prefs.getString("uid");
      final actorName = prefs.getString("username");

      final connectivity = await Connectivity().checkConnectivity();
      final isOnline = connectivity.any((result) => result != ConnectivityResult.none);

      Map<String, dynamic> adData = {
        "title": title,
        "categoryId": categoryId,
        "subCategoryId": subCategoryId,
        "productId": productId,
        "productName": productName,
        "quantity": quantity,
        "unit": unit,
        "price": price,
        "description": description,
        "breed": breed,
        "images": images.map((f) => f.path).toList(),
      };

      if (!isOnline) {
        await saveOfflineAd(adData);
        isLoading = false;
        notifyListeners();
        return {"status": 0, "body": "No internet. Ad saved offline"};
      }

      final url = Uri.parse(ApiConstants.createAds);
      var request = http.MultipartRequest("POST", url);

      // Normal fields
      request.fields["title"] = title;
      request.fields["category_id"] = categoryId;
      request.fields["subcategory_id"] = subCategoryId;
      request.fields["product_id"] = productId;
      request.fields["product_name"] = productName;
      request.fields["quantity"] = quantity;
      request.fields["unit"] = unit;
      request.fields["price"] = price;
      request.fields["description"] = description;
      request.fields["ad_type"] = "sell";
      request.fields["post_type"] = "postnow";
      request.fields["created_by_role"] = "user";
      request.fields["creator_id"] = creatorId ?? "";
      request.fields["actor_name"] = actorName ?? "";
      request.fields["districts"] = jsonEncode([district ?? "Unknown"]);
      request.fields["extra_fields"] = jsonEncode({"breed": breed});

      // Images
      for (var img in images) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "images",
            img.path,
            contentType: MediaType("image", "jpeg"),
          ),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      isLoading = false;
      notifyListeners();

      return {"status": response.statusCode, "body": response.body};
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return {"status": 0, "body": e.toString()};
    }
  }

  void resetCropForm() {
    selectedBreed = null;
    breedOptions = [];
    notifyListeners();
  }

  void resetForm() {
    selectedBreed = null;
    breedOptions = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
