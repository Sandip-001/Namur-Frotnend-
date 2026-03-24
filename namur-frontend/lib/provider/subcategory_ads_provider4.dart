import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ads_filter_model.dart';
import '../models/othersad_model.dart';
import '../utils/api_url.dart';

class SubCategoryAdsProvider with ChangeNotifier {
  /// Final displayed list
  List<OtherAdModel> ads = [];

  /// Backup list for stacked filters
  List<OtherAdModel> originalAds = [];

  bool isLoading = false;

  /// ─────────────────────────────────────────────
  /// BASIC FETCH (same API as your old fetchAds)
  /// ─────────────────────────────────────────────
  Future<void> fetchAdsBySubCategory({
    required String subCategory,

  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final district = prefs.getString("district") ?? "";

      final uri = Uri.parse(
        ApiConstants.filterAdsBySubcategory(
          district: district,
          subcategoryName: subCategory,
        ),
      );


print(uri);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        ads = data.map((e) => OtherAdModel.fromJson(e)).toList();

        /// backup for stacked filters
        originalAds = List.from(ads);
      } else {
        ads.clear();
        originalAds.clear();
      }
    } catch (e) {
      debugPrint("SubCategory Fetch Error → $e");
      ads.clear();
      originalAds.clear();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ─────────────────────────────────────────────
  /// STACKED FILTER (NO API CHANGE)
  /// ─────────────────────────────────────────────
  Future<void> fetchAdsWithFilterStacked(AdsFilter filter, {String? subcategoryName}) async {
    if (originalAds.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      final String url = (subcategoryName != null && subcategoryName.isNotEmpty)
          ? ApiConstants.filteredBySubcategory(
              subcategoryName: subcategoryName,
              sort: filter.sort ?? "price_low_to_high",
              district: filter.district,
            )
          : "${ApiConstants.baseUrl}/ads/sort-filter?${filter.toQueryParams().entries.map((e) => "${e.key}=${e.value}").join("&")}";

      debugPrint("STACK FILTER URL → $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List data =
        decoded is Map ? decoded['data'] ?? [] : decoded;

        final List<OtherAdModel> filtered =
        data.map((e) => OtherAdModel.fromJson(e)).toList();

        if (subcategoryName != null && subcategoryName.isNotEmpty) {
          /// Use API results directly for subcategory filter
          ads = filtered;
        } else {
          /// intersection (stacking) for other filters
          ads = originalAds
              .where((ad) => filtered.any((f) => f.id == ad.id))
              .toList();
        }
      }
    } catch (e) {
      debugPrint("Stack Filter Error → $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ─────────────────────────────────────────────
  /// SORT ONLY (same API family)
  /// ─────────────────────────────────────────────
  Future<void> fetchSortedAds({
    required int subCategoryId,
    required String sortType,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final district = prefs.getString("district") ?? "";

      final url =
          "${ApiConstants.baseUrl}/ads/sort-filter"
          "?subcategory_id=$subCategoryId"
          "&district=$district"
          "&sort=$sortType";

      debugPrint("SORT URL → $url");

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List list =
        decoded is Map ? decoded['data'] ?? [] : decoded;

        ads = list.map((e) => OtherAdModel.fromJson(e)).toList();
        originalAds = List.from(ads);
      }
    } catch (e) {
      debugPrint("Sort Error → $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ─────────────────────────────────────────────
  /// RESET FILTER
  /// ─────────────────────────────────────────────
  void resetFilters() {
    ads = List.from(originalAds);
    notifyListeners();
  }

  /// ─────────────────────────────────────────────
  /// CLEAR
  /// ─────────────────────────────────────────────
  void clear() {
    ads.clear();
    originalAds.clear();
    notifyListeners();
  }
}
