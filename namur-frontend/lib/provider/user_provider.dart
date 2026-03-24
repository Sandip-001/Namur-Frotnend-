import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_namur_frontend/models/land_product_model.dart';
import 'package:the_namur_frontend/services/profile_service.dart';
import '../models/user_model.dart';
import '../utils/api_url.dart';
class UserProvider extends ChangeNotifier {
  AuthUser? user;
  List<LandItem> myStock = [];
  bool isLoading = false;
  bool isProfileLoaded = false;
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();

    user = AuthUser(
      firebaseUid: prefs.getString("firebase_uid"),
      email: prefs.getString("email"),
      username: prefs.getString("username"),
      mobile: prefs.getString("mobile"),

      district: prefs.getString("district"),
      taluk: prefs.getString("taluk"),
      village: prefs.getString("village"),
      panchayat: prefs.getString("panchayat"),

      profession: prefs.getString("profession"),
      profileImageUrl: prefs.getString("profile_image_url"),
    );

    notifyListeners();
  }

  Future<bool> updateExtra({required Map<String, dynamic> body}) async {
    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/user/update-extra"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    print("name change request");
    print(body);
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future<void> saveFetchedProfile(AuthUser fetched) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("firebase_uid", fetched.firebaseUid ?? "");
    await prefs.setString("uid", fetched.id?.toString() ?? "");
    await prefs.setString("email", fetched.email ?? "");
    await prefs.setString("username", fetched.username ?? "");
    await prefs.setString("mobile", fetched.mobile ?? "");

    // 🔥 LOCATION (THIS WAS MISSING EARLIER)
    await prefs.setString("district", fetched.district ?? "");
    await prefs.setString("taluk", fetched.taluk ?? "");
    await prefs.setString("village", fetched.village ?? "");
    await prefs.setString("panchayat", fetched.panchayat ?? "");

    await prefs.setString("profession", fetched.profession ?? "");
    await prefs.setString("profile_image_url", fetched.profileImageUrl ?? "");

    user = fetched;
    notifyListeners();
  }

  Future<void> updateProfileImage(String newUrl) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("profile_image_url", newUrl);

    if (user != null) {
      user!.profileImageUrl = newUrl;
    }

    notifyListeners();
  }

  final ProfileService _service = ProfileService();

  /// 🔥 Always fetch fresh profile from API
  Future<void> fetchProfile() async {
    final fetchedUser = await _service.fetchProfileDetails();

    if (fetchedUser != null) {
      await saveFetchedProfile(fetchedUser); // Sync to SP
      isProfileLoaded = true;
      notifyListeners();
    }
  }

  Future<void> fetchMyStock() async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("uid");
    try {
      isLoading = true;
      notifyListeners();
      final url = Uri.parse(
        ApiConstants.landProductsByUser(userId ?? "6"),
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        myStock = data.map((e) => LandItem.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error: $e");
    }

    isLoading = false;
    notifyListeners();
  }
}
