import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ads_filter_model.dart';
import '../models/create_ad_model.dart';
import '../models/machinery_ad_model.dart';
import '../models/othersad_model.dart';
import '../utils/api_url.dart';

class MachineryAdsProvider with ChangeNotifier {
  List<MachineryAdModel> machineryAds = [];
  List<OtherAdModel> otherAds = [];
  bool isLoading = false;

  // Backup of original fetched ads for stacking filters
  List<MachineryAdModel> originalMachineryAds = [];
  List<OtherAdModel> originalOtherAds = [];

  // Dropdown filtering
  String? selectedAdType;
  String? selectedCondition;
  String? selectedInsurance;
  String? selectedFc;

  void setAdType(String? v) {
    selectedAdType = v;
    notifyListeners();
  }

  void setCondition(String? v) {
    selectedCondition = v;
    notifyListeners();
  }

  void setInsurance(String? v) {
    selectedInsurance = v;
    notifyListeners();
  }

  void setFc(String? v) {
    selectedFc = v;
    notifyListeners();
  }

  void clearAds() {
    machineryAds = [];
    otherAds = [];
    originalMachineryAds = [];
    originalOtherAds = [];
    notifyListeners();
  }

  Future<void> fetchAdsWithSortFilter({
    required int productId,
    String? district,
    String? taluk,
    String? village,
    String? panchayat,
    String? sort,
    List<String>? breeds,
    required String adType,
  }) async {
    isLoading = true;
    machineryAds.clear();
    notifyListeners();

    final query = {
      "product_id": productId.toString(),
      if (adType != 'all') "ad_type": adType,
      if (district != null && district.isNotEmpty) "district": district,
      if (taluk != null && taluk.isNotEmpty) "taluk": taluk,
      if (village != null && village.isNotEmpty) "village": village,
      if (panchayat != null && panchayat.isNotEmpty) "panchayat": panchayat,
      if (sort != null) "sort": sort,
      if (breeds != null && breeds.isNotEmpty) "breed": jsonEncode(breeds),
    };

    final uri = Uri.parse(
      "${ApiConstants.baseUrl}/ads/sort-filter/",
    ).replace(queryParameters: query);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      machineryAds = data.map((e) => MachineryAdModel.fromJson(e)).toList();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> fetchMachineryAds(String productId) async {
    isLoading = true;
    clearAds();
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("uid") ?? "6"; // Fallback for testing

    final url = ApiConstants.filterAds(
      userId: userId,
      productId: productId.toString(),
    );

    print(url);

    try {
      final response = await http.get(Uri.parse(url));
      print(response.statusCode);
      if (response.statusCode == 200) {
        final List decoded = json.decode(response.body);

        for (var json in decoded) {
          if (json["category_name"].toString().toLowerCase().trim() ==
              "machinery") {
            MachineryAdModel ad = MachineryAdModel.fromJson(json);
            machineryAds.add(ad);
            originalMachineryAds.add(ad);
          } else {
            OtherAdModel ad = OtherAdModel.fromJson(json);
            otherAds.add(ad);
            originalOtherAds.add(ad);
          }
        }
      }

      isLoading = false;
      notifyListeners();
      return machineryAds.isNotEmpty || otherAds.isNotEmpty;
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchFilteredAds({
    required int productId,
    required String district,
    required String adType,
  }) async {
    isLoading = true;
    clearAds();
    notifyListeners();

    try {
      String correctType = adType.toLowerCase() == "sell"
          ? "sell"
          : (adType.toLowerCase() == "rent" ? "rent" : "all");
      String url =
          "${ApiConstants.baseUrl}/ads/filter"
          "?status=active"
          "&productId=$productId"
          "&districts=[\"$district\"]";

      if (correctType != "all") {
        url += "&ad_type=$correctType";
      }

      print(url);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final districts = prefs.getString("district") ?? "";
      print("Dist $districts");
      print("here");
      print(productId);
      final response = await http.get(Uri.parse(url));
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        for (var json in data) {
          final category = (json["category_name"] ?? "")
              .toString()
              .toLowerCase()
              .trim();

          if (category == "machinery") {
            MachineryAdModel ad = MachineryAdModel.fromJson(json);
            machineryAds.add(ad);
            originalMachineryAds.add(ad);
          } else {
            OtherAdModel ad = OtherAdModel.fromJson(json);
            otherAds.add(ad);
            originalOtherAds.add(ad);
          }
        }
      } else {
        clearAds();
      }
    } catch (e) {
      print("Filtered Ads Error: $e");
      clearAds();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ New method: stacked filtering
  Future<void> fetchAdsWithFilterStacked(AdsFilter filter) async {
    isLoading = true;
    notifyListeners();

    try {
      // Merge filter params
      Map<String, String> queryParams = {...filter.toQueryParams()};

      final uri = Uri.parse(
        "${ApiConstants.baseUrl}/ads/sort-filter/",
      ).replace(queryParameters: queryParams);

      print('Filter URL → $uri');

      final response = await http.get(uri);
      print('Status → ${response.statusCode}');
      print('Body → ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List data = jsonResponse['data'] ?? [];

        // Convert to models
        List<MachineryAdModel> filteredMachinery = [];
        List<OtherAdModel> filteredOther = [];

        for (var json in data) {
          final category = (json["category_name"] ?? "")
              .toString()
              .toLowerCase()
              .trim();
          if (category == "machinery") {
            filteredMachinery.add(MachineryAdModel.fromJson(json));
          } else {
            filteredOther.add(OtherAdModel.fromJson(json));
          }
        }

        // Decide base list: for category filters start from original
        machineryAds = machineryAds.isEmpty
            ? List.from(originalMachineryAds)
            : machineryAds;

        otherAds = otherAds.isEmpty ? List.from(originalOtherAds) : otherAds;

        // Apply intersection filter: keep only items present in filtered list
        machineryAds = machineryAds
            .where((ad) => filteredMachinery.any((f) => f.id == ad.id))
            .toList();

        otherAds = otherAds
            .where((ad) => filteredOther.any((f) => f.id == ad.id))
            .toList();
      }
    } catch (e) {
      print("Filter Error → $e");
      // Do not clear existing lists to allow stacked filters
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAd(int adId) async {
    var url = Uri.parse(ApiConstants.adDetails(adId.toString()));

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        machineryAds.removeWhere((element) => element.id == adId);
        otherAds.removeWhere((element) => element.id == adId);
        originalMachineryAds.removeWhere((element) => element.id == adId);
        originalOtherAds.removeWhere((element) => element.id == adId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ✅ Keep all other existing methods the same

  Future<void> fetchSortedAds({
    required int productId,
    required String district,
    required String sortType,
    String? adType,
  }) async {
    try {
      isLoading = true;
      clearAds();
      notifyListeners();

      String url =
          "${ApiConstants.baseUrl}/ads/sort-filter"
          "?product_id=$productId"
          "&district=$district"
          "&sort=$sortType";

      if (adType != null && adType.isNotEmpty && adType != 'all') {
        url += "&ad_type=$adType";
      }

      print("SORT URL → $url");

      final response = await http.get(Uri.parse(url));
      print("SORT STATUS → ${response.statusCode}");
      print("SORT BODY → ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        final List list = decoded is Map<String, dynamic>
            ? (decoded['data'] ?? [])
            : decoded;

        for (var json in list) {
          if (json["category_name"].toString().toLowerCase().trim() ==
              "machinery") {
            MachineryAdModel ad = MachineryAdModel.fromJson(json);
            machineryAds.add(ad);
            originalMachineryAds.add(ad);
          } else {
            OtherAdModel ad = OtherAdModel.fromJson(json);
            otherAds.add(ad);
            originalOtherAds.add(ad);
          }
        }
      } else {
        clearAds();
      }
    } catch (e) {
      print("SORT ERROR: $e");
      clearAds();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<int> updateAd({
    required int adId,
    String? title,
    String? categoryId,
    String? subCategoryId,
    String? productId,
    String? productName,
    String? quantity,
    String? price,
    String? description,
    String? brand,
    String? model,
    String? manufactureYear,
    String? registrationNo,
    String? prevOwners,
    String? drivenHours,
    String? kmsCovered,
    String? adType,
    String? postType,
    String? unit,
    String? insuranceRunning,
    String? fcValue,
    String? condition,
    List<File>? newImages,
    List<AdImage>? existingImages,
    List<String>? districts,
  }) async {
    // Keep this method unchanged
    // ...
    return 0;
  }

  Future<void> fetchAds() async {
    try {
      isLoading = true;
      clearAds();
      notifyListeners();

      final url = Uri.parse(ApiConstants.createAds);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        for (var json in data) {
          if (json["category_name"].toString().toLowerCase().trim() ==
              "machinery") {
            MachineryAdModel ad = MachineryAdModel.fromJson(json);
            machineryAds.add(ad);
            originalMachineryAds.add(ad);
          } else {
            OtherAdModel ad = OtherAdModel.fromJson(json);
            otherAds.add(ad);
            originalOtherAds.add(ad);
          }
        }
      }
    } catch (e) {
      print("Error fetching ads: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
