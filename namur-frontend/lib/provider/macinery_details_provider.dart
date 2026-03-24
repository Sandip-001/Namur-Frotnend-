import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_url.dart';

class MachineryProvider with ChangeNotifier {
  bool isLoading = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isSyncingOfflineAds = false;

  MachineryProvider() {
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

  // Dropdown selections
  String? selectedAdType;
  String? selectedCondition;
  String? selectedInsurance;
  String? selectedFc;

  void setAdType(String? val) {
    selectedAdType = val;
    notifyListeners();
  }

  void setCondition(String? val) {
    selectedCondition = val;
    notifyListeners();
  }

  void setInsurance(String? val) {
    selectedInsurance = val;
    notifyListeners();
  }

  void setFc(String? val) {
    selectedFc = val;
    notifyListeners();
  }

  void setLoading(bool val) {
    isLoading = val;
    notifyListeners();
  }

  // ------------------------------
  // SAVE OFFLINE AD (HIVE)
  // ------------------------------
  Future<void> saveOfflineAd(Map<String, dynamic> ad) async {
    final box = await Hive.openBox("pending_machine_ads");
    await box.add(ad);
    print("💾 Saved offline: ${ad['title']}");
  }

  // ------------------------------
  // TRY UPLOADING ALL OFFLINE ADS
  // ------------------------------
  Future<void> tryUploadOfflineAds() async {
    if (_isSyncingOfflineAds) return;
    _isSyncingOfflineAds = true;

    final box = await Hive.openBox("pending_machine_ads");

    if (box.isEmpty) {
      print("No pending ads to upload.");
      _isSyncingOfflineAds = false;
      return;
    }

    print("📡 Trying to upload offline ads…");

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
        print("⚠️ Missing image file(s), skipping offline machine ad: ${ad["title"]}");
        continue;
      }

      final response = await createAdFromMap(ad);
      final status = response["status"] ?? 0;

      if (status == 200 || status == 201) {
        print("✔ Uploaded offline ad: ${ad["title"]}");
        await box.delete(key);
      } else {
        print("❌ Failed again, keeping offline. Error: ${response["body"]}");
      }
    }

    _isSyncingOfflineAds = false;
  }

  // ------------------------------
  // Create ad from offline Map
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
      price: ad["price"],
      description: ad["description"],
      brand: ad["brand"],
      model: ad["model"],
      manufactureYear: ad["manufactureYear"],
      registrationNo: ad["registrationNo"],
      prevOwners: ad["prevOwners"],
      drivenHours: ad["drivenHours"],
      kmsCovered: ad["kmsCovered"],
      images: images,
      machineCondition: ad["machineCondition"] ?? '',
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
    required String price,
    required String description,
    required String brand,
    required String model,
    required String manufactureYear,
    required String registrationNo,
    required String prevOwners,
    required String drivenHours,
    required String kmsCovered,
    required List<File> images,
    required String? machineCondition,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final district = prefs.getString("district");
      final creatorId = prefs.getString("uid");
      final actorName = prefs.getString("username");

      final url = Uri.parse(ApiConstants.createAds);
      var request = http.MultipartRequest("POST", url);

      // Normal fields
      request.fields["title"] = title;
      request.fields["category_id"] = categoryId;
      request.fields["subcategory_id"] = subCategoryId;
      request.fields["product_id"] = productId;
      request.fields["product_name"] = productName;
      request.fields["quantity"] = quantity;
      request.fields["price"] = price;
      request.fields["description"] = description;
      request.fields["ad_type"] = selectedAdType ?? "Sell";
      request.fields["post_type"] = "postnow";
      request.fields["created_by_role"] = "user";
      request.fields["creator_id"] = creatorId ?? "";
      request.fields["actor_name"] = actorName ?? "";
      request.fields["districts"] = jsonEncode([district ?? "Unknown"]);

      // Extra fields
      request.fields["extra_fields"] = jsonEncode({
        "brand": brand,
        "model": model,
        "manufacture_year": int.tryParse(manufactureYear) ?? 0,
        "registration_no": registrationNo,
        "prev_owners": int.tryParse(prevOwners) ?? 0,
        "driven_hours": int.tryParse(drivenHours) ?? 0,
        "kms_covered": int.tryParse(kmsCovered) ?? 0,
        "insurance_running": selectedInsurance ?? "Yes",
        "fc_value": selectedFc ?? "Yes",
        "machine_condition": selectedCondition ?? "New",
      });

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

      // Send request
      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);
      print("machine ad----");
      print(url);
      print(response.statusCode);
      print(response.body);

      isLoading = false;
      notifyListeners();

      // Return status + body
      return {"status": response.statusCode, "body": response.body};
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return {"status": 0, "body": e.toString()};
    }
  }

  void resetForm() {
    selectedAdType = null;
    selectedCondition = null;
    selectedInsurance = null;
    selectedFc = null;
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
