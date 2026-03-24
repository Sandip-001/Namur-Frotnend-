import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/othersad_model.dart';
import '../models/create_ad_model.dart';
import '../utils/api_url.dart';

class ProductAdsProvider with ChangeNotifier {
  List<OtherAdModel> ads = [];
  bool isLoading = false;

  // ------------------------------------------------
  // FETCH ADS LIST
  // ------------------------------------------------
  Future<bool> fetchProductAds(String userId, int productId) async {
    isLoading = true;
    notifyListeners();

    final url = ApiConstants.filterAds(
      userId: userId,
      productId: productId.toString(),
    );

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List decoded = json.decode(response.body);
        ads = decoded.map((e) => OtherAdModel.fromJson(e)).toList();
        print(url);
        print(ads);
        isLoading = false;
        notifyListeners();
        return ads.isNotEmpty;
      } else {
        isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ------------------------------------------------
  // DELETE AD
  // ------------------------------------------------
  Future<bool> deleteAd(int adId) async {
    var url = Uri.parse(ApiConstants.adDetails(adId.toString()));

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        ads.removeWhere((element) => element.id == adId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ------------------------------------------------
  // UPDATE AD (MULTIPART FORM-DATA)
  // ------------------------------------------------
  Future<bool> updateAd({
    required int adId,
    required String title,
    required String quantity,
    required String price,
    required String description,
    required String unit,
    required String breed,

    required List<AdImage> existingImages, // OLD IMAGES (WITH PUBLIC ID)
    required List<File> newImages, // NEW IMAGES
  }) async {
    try {
      var url = Uri.parse(ApiConstants.adDetails(adId.toString()));
      var request = http.MultipartRequest("PUT", url);

      // -----------------------------
      // NORMAL FIELDS
      // -----------------------------
      request.fields["title"] = title;
      request.fields["quantity"] = quantity;
      request.fields["price"] = price;
      request.fields["description"] = description;
      request.fields["unit"] = unit;
      request.fields["breed"] = breed;

      // -----------------------------
      // EXISTING IMAGES → PUBLIC IDs
      // -----------------------------
      /* for (var img in existingImages) {
        request.fields["images"] = img.publicId ?? "";
      }*/
      print(" EXISTING IMAGES");
      print(existingImages);
      print("New Images");
      print(newImages);
      // ---------- EXISTING IMAGES ----------
      List<String> publicIds = existingImages
          .where((img) => img.publicId.isNotEmpty)
          .map((img) => img.publicId)
          .toList();

      request.fields["existingImages"] = jsonEncode(publicIds);

      // ---------- NEW IMAGES ----------
      for (var file in newImages) {
        request.files.add(
          await http.MultipartFile.fromPath("images", file.path),
        );
      }

      print("FILES:");
      for (var file in request.files) {
        print(
          "${file.field}: ${file.filename}, length: ${file.length}, contentType: ${file.contentType}",
        );
      }

      // -----------------------------
      // SEND REQUEST
      // -----------------------------
      var response = await request.send();
      var resp = await response.stream.bytesToString();

      print("EDIT STATUS = ${response.statusCode}");
      print("EDIT BODY = $resp");

      return response.statusCode == 200;
    } catch (e) {
      print("UPDATE ERROR => $e");
      return false;
    }
  }

  // Fetch ads with sort and filter
  Future<void> fetchAds({
    required int productId,
    required String district,
    String? sort, // "price_low_to_high" or "price_high_to_low"
    List<String>? breeds,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      String breedParam = "";
      if (breeds != null && breeds.isNotEmpty) {
        breedParam = "&breed=${breeds.join(',')}";
      }

      String sortParam = "";
      if (sort != null && sort.isNotEmpty) {
        sortParam = "&sort=$sort";
      }

      String url =
          "${ApiConstants.baseUrl}/ads/sort-filter/?product_id=$productId&district=$district$sortParam$breedParam";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map data = json.decode(response.body);
        if (data["success"] == true) {
          ads = (data["data"] as List)
              .map((e) => OtherAdModel.fromJson(e))
              .toList();
        } else {
          ads = [];
        }
      } else {
        ads = [];
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      ads = [];
      notifyListeners();
      print("Fetch Ads Error: $e");
    }
  }
}
