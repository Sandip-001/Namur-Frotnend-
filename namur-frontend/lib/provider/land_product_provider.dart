import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/land_product_model.dart';
import '../utils/api_url.dart';

class LandProductProvider extends ChangeNotifier {
  bool isSaving = false;
  int? selectedLandId;
  /// Store fetched products: keyed by category
  final Map<String, List<dynamic>> _items = {
    "food": [],
    "machinery": [],
    "animal": []
  };

  /// Loading states for each category
  final Map<String, bool> _loading = {
    "food": false,
    "machinery": false,
    "animal": false
  };

  // -----------------------------------------------------------
  // GETTERS
  // -----------------------------------------------------------
  List<dynamic> getItems(String category) => _items[category] ?? [];

  bool isLoadingFor(String category) => _loading[category] ?? false;
  // -----------------------------------------------------------


  // -----------------------------------------------------------
  // FETCH LAND PRODUCTS BY CATEGORY
  // -----------------------------------------------------------
  Future<void> fetchLandProducts({
    required int landId,
  }) async {
    try {
      // Clear all categories before loading
      _items["food"] = [];
      _items["animal"] = [];
      _items["machinery"] = [];

      _loading["food"] = true;
      _loading["animal"] = true;
      _loading["machinery"] = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("uid");

      if (userId == null) {
        _loading["food"] = false;
        _loading["animal"] = false;
        _loading["machinery"] = false;
        notifyListeners();
        return;
      }

      final url = Uri.parse(
          "${ApiConstants.getLandProducts}/$userId/$landId"
      );

      print(url);

      final response = await http.get(url);

      _loading["food"] = false;
      _loading["animal"] = false;
      _loading["machinery"] = false;

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        List dataList;

        // API returns LIST directly
        if (jsonData is List) {
          dataList = jsonData;
        }
        // API returns MAP with data
        else if (jsonData is Map && jsonData["data"] is List) {
          dataList = jsonData["data"];
        } else {
          dataList = [];
        }

        // -------------------------------------------------
        // 🔥 Filter by category locally
        // -------------------------------------------------
        for (var item in dataList) {
          String cat = (item["category"] ?? "").toString().toLowerCase();

          final formattedItem = {
            "product_name": item["product_name"],
            "acres": item["acres"],
            "quantity": item["quantity"],
            "id": item["id"],
            "category": item["category"],
          };

          if (cat.contains("food")) {
            _items["food"]!.add(formattedItem);
          } else if (cat.contains("animal")) {
            _items["animal"]!.add(formattedItem);
          } else if (cat.contains("machinery")) {
            _items["machinery"]!.add(formattedItem);
          }
        }
      }

      notifyListeners();
    } catch (e) {
      print("Fetch Products Error: $e");

      _loading["food"] = false;
      _loading["animal"] = false;
      _loading["machinery"] = false;

      notifyListeners();
    }
  }


  // -----------------------------------------------------------
  // SAVE LAND PRODUCT (CROP)
  // -----------------------------------------------------------
  Future<String?> saveLandProduct({
    required int landId,
    required int productId,
    required String acres,
  }) async {
    print('calling save land');
    try {
      isSaving = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("uid");

      if (userId == null) {
        isSaving = false;
        notifyListeners();
        return null;
      }

      final url = Uri.parse(ApiConstants.createLandProduct);

      final body = {
        "user_id": int.parse(userId),
        "land_id": landId,
        "product_id": productId,
        "acres": acres,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
print(response.statusCode);
print(response.body);
      isSaving = false;
      notifyListeners();

      if (response.statusCode == 200) {
        return LandProductModel.fromJson(jsonDecode(response.body)).message;
      }
      else
        {
          final errorBody = jsonDecode(response.body);
          final message = errorBody['message'] ?? 'Something went wrong';
          return message;
        }

      return null;
    } catch (e) {
      isSaving = false;
      notifyListeners();
      print("Save Error: $e");
      return null;
    }
  }

  // -----------------------------------------------------------
  // SAVE MACHINERY DETAILS
  // -----------------------------------------------------------
  Future<String?> saveMachinery({
    required int landId,
    required int productId,
    required String modelNo,
    required String regNo,
    required String chassiNo,
    required String rcCopyNo,
  }) async {
    try {
      isSaving = true;
      notifyListeners();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("uid");

      if (userId == null) return null;

      final url = Uri.parse(ApiConstants.createLandProduct);

      final body = {
        "user_id": int.parse(userId),
        "land_id": landId,
        "product_id": productId,
        "model_no": modelNo,
        "registration_no": regNo,
        "chassi_no": chassiNo,
        "rc_copy_no": rcCopyNo,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      isSaving = false;
      notifyListeners();

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json["message"];
      }

      return null;
    } catch (e) {
      isSaving = false;
      notifyListeners();
      print("Save Machinery Error: $e");
      return null;
    }
  }

  // -----------------------------------------------------------
  // SAVE ANIMALS
  // -----------------------------------------------------------
  Future<String?> saveAnimal({
    required int landId,
    required int productId,
    required String quantity,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("uid");

      if (userId == null) return null;

      final url = Uri.parse(ApiConstants.createLandProduct);

      final body = {
        "user_id": int.parse(userId),
        "land_id": landId,
        "product_id": productId,
        "quantity": int.parse(quantity),
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return LandProductModel.fromJson(jsonDecode(response.body)).message;
      }

      return null;
    } catch (e) {
      print("Animal Save Error: $e");
      return null;
    }
  }

  void resetAll() {
    _items["food"] = [];
    _items["animal"] = [];
    _items["machinery"] = [];
    notifyListeners();
  }
}
