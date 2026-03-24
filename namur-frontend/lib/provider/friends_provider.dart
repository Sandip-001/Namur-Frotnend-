import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_url.dart';

class FriendsProvider extends ChangeNotifier {
  int _friendsCount = 0;
  final bool _isLoadingFriends = false;

  List<dynamic> _groups = [];
  bool _isLoadingGroups = false;

  // 🔥 NEW: District group count
  int _districtGroupCount = 0;
  final bool _isLoadingDistrictGroups = false;

  int get friendsCount => _friendsCount;
  bool get isLoadingFriends => _isLoadingFriends;

  List<dynamic> get groups => _groups;
  bool get isLoadingGroups => _isLoadingGroups;

  // 🔥 NEW getters
  int get districtGroupCount => _districtGroupCount;
  bool get isLoadingDistrictGroups => _isLoadingDistrictGroups;

  // ================= FRIENDS COUNT (DEPRECATED: Use fetchDistrictGroupCount) =================
  Future<void> fetchFriendsCount() async {
    // This method is deprecated as it calculates count by matching ads,
    // which does not align with the requirement to use the 'totalFriends' field.
    return;
  }

  // ================= USER GROUP DETAILS =================
  Future<void> fetchUserGroups(
    int userId, {
    String categoryName = "food",
  }) async {
    _isLoadingGroups = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userid = prefs.getString("uid");

      if (userid == null) {
        _groups = [];
        return;
      }

      final uri = Uri.parse(ApiConstants.landProductByUserFood(userid));
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        _groups = json.decode(response.body);
      } else {
        _groups = [];
      }
    } catch (e) {
      _groups = [];
      debugPrint("Error fetching user groups: $e");
    }

    _isLoadingGroups = false;
    notifyListeners();
  }

  // ================= 🔥 DISTRICT GROUP COUNT =================
  Future<void> fetchDistrictGroupCount() async {
    _isLoadingGroups = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final district = prefs.getString("district");
      final userId = prefs.getString("uid");

      if (district == null) {
        _districtGroupCount = 0;
        return;
      }

      final uri = Uri.parse(
        "https://api.inkaanalysis.com/api/ads/user/$userId/district/$district",
      );
      print(uri);
      final response = await http.get(uri);

      print("API => $uri");
      print("RESPONSE => ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);

        _districtGroupCount = jsonMap['totalGroups'] ?? 0;
        _friendsCount = jsonMap['totalFriends'] ?? 0;
        _groups = List.from(jsonMap['groups'] ?? []);
      } else {
        _districtGroupCount = 0;
        _groups = [];
      }
    } catch (e) {
      _districtGroupCount = 0;
      _groups = [];
      print("Error fetching district group count: $e");
    }

    _isLoadingGroups = false;
    notifyListeners();
  }
}
