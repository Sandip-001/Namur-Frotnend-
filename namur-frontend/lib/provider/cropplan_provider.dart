import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cropplan_model.dart';
import 'package:intl/intl.dart';

import '../utils/api_url.dart';
class CropCalendarItem {
  final int id;
  final int userId;
  final int landId;
  final int productId;
  final String areaAcres;
  final String planningDate;
  final String createdAt;
  final String updatedAt;
  final String? landName;       // make nullable
  final String? landFarmSize;   // make nullable
  final String productName;
  final String productImage;

  CropCalendarItem({
    required this.id,
    required this.userId,
    required this.landId,
    required this.productId,
    required this.areaAcres,
    required this.planningDate,
    required this.createdAt,
    required this.updatedAt,
    this.landName,        // nullable
    this.landFarmSize,    // nullable
    required this.productName,
    required this.productImage,
  });

  factory CropCalendarItem.fromJson(Map<String, dynamic> json) {
    return CropCalendarItem(
      id: json["id"],
      userId: json["user_id"],
      landId: json["land_id"],
      productId: json["product_id"],
      areaAcres: json["area_acres"],
      planningDate: json["planning_date"],
      createdAt: json["created_at"],
      updatedAt: json["updated_at"],
      landName: json["land_name"],            // null accepted
      landFarmSize: json["land_farm_size"],  // null accepted
      productName: json["product_name"],
      productImage: json["product_image"],
    );
  }
}

class CropPlanProvider with ChangeNotifier {
  bool isLoading = false;
  bool isCropLoading = false;
  List<CropPlanModel> crops = [];
  List<CropCalendarItem> cropPlans = [];
  int? selectedCropPlanId;
  int? selectedCropId;
  CropPlanModel? selectedCrop;

  /// FETCH CROP PLAN LIST
  Future<void> fetchCropPlans() async {
    isLoading = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("uid") ?? "6"; // Fallback for testing

    final url = Uri.parse(ApiConstants.cropPlanByUser(userId));

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List decoded = jsonDecode(response.body);
        cropPlans = decoded.map((json) => CropCalendarItem.fromJson(json)).toList();

        // ✅ AUTO SELECT FIRST CROP PLAN
        if (cropPlans.isNotEmpty && selectedCropId == null) {
          await setSelectedCrop(cropPlans.first); // await so calendar is fetched
        }
      } else {
        cropPlans = [];
      }
    } catch (e) {
      cropPlans = [];
      print("Error fetching crop plans: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> stopTracking(int cropPlanId) async {
    try {
      final url = "${ApiConstants.baseUrl}/crop-plan/$cropPlanId";
print(url);
      final response = await http.delete(Uri.parse(url));
print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 204) {
        // ✅ RESET SELECTION IF THE DELETED ONE WAS CURRENTLY SELECTED
        if (selectedCropPlanId == cropPlanId) {
          selectedCropPlanId = null;
          selectedCropId = null;
          selectedCrop = null;
        }

        await fetchCropPlans(); // Refresh fresh list

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print("Stop tracking error: $e");
      return false;
    }
  }

  /// SELECT CROP
  Future<void> setSelectedCrop(CropCalendarItem crop) async {

    selectedCrop = null; // reset
    isCropLoading = true;
    selectedCropId = crop.productId;     // ✅ product id
    selectedCropPlanId = crop.id;
    notifyListeners();

    await fetchCropCalendar(crop.productId);

    isCropLoading = false;
    notifyListeners();
  }

  /// FETCH CALENDAR DETAILS
  Future<void> fetchCropCalendar(int productId) async {
    final url = Uri.parse(ApiConstants.cropCalendarByProduct(productId));

    print("CALENDAR API CALL => $url");

    try {
      final response = await http.get(url);
      print("API RESPONSE: ${response.body}");

      if (response.statusCode == 200 &&
          response.body.isNotEmpty &&
          response.body != "{}") {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          crops = decoded.map((e) => CropPlanModel.fromJson(e)).toList();
          if (crops.isNotEmpty) {
            selectedCrop = crops.first;
          } else {
            selectedCrop = null;
          }
        } else if (decoded is Map<String, dynamic>) {
          // If the API returns a single object
          selectedCrop = CropPlanModel.fromJson(decoded);
          crops = [selectedCrop!];
        } else {
          selectedCrop = null;
        }
      } else {
        selectedCrop = null;
      }
    } catch (e) {
      print("Error fetching crop calendar: $e");
      selectedCrop = null;
    }

    notifyListeners();
  }

  Future<bool> updatePlanningDate(int planId, String date) async {
    final url = Uri.parse(ApiConstants.getCropPlanById(planId));

    try {
      final body = jsonEncode({"planning_date": date});
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // refresh crop plans (to update the planning_date in the list)
        await fetchCropPlans();

        // if we have a selected product, refresh its calendar details
        if (selectedCropId != null) {
          await fetchCropCalendar(selectedCropId!);
        }

        return true;
      } else {
        // server returned an error
        debugPrint('Update planning date failed: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Exception updating planning date: $e');
      return false;
    }
  }

  DateTime addDaysToPlanningDate(String planningDate, int days) {
    final date = DateTime.parse(planningDate);
    return date.add(Duration(days: days));
  }

  String formatCalendarDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return "Today";
    }

    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return "Tomorrow";
    }

    return DateFormat("ddMMMyy").format(date); // Example: 10Mar23
  }

}
