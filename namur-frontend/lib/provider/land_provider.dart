import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


import '../models/land_model.dart';
import '../utils/api_url.dart';

class LandDetailsProvider with ChangeNotifier {
  // -------------------------------------------------------
  // TEXT CONTROLLERS
  // -------------------------------------------------------
  final TextEditingController farmNameController = TextEditingController();
  final TextEditingController surveyNoController = TextEditingController();
  final TextEditingController hissaNoController = TextEditingController();
  final TextEditingController farmSizeController = TextEditingController();
  final TextEditingController panchayatController = TextEditingController();
  String? errorMessage;
  bool isSaving = false;
  bool isLoadingList = false;

  // For listing lands
  List<LandModel> _lands = [];
  List<LandModel> get lands => _lands;

  // For specific land (edit)
  LandModel? _selectedLand;
  LandModel? get selectedLand => _selectedLand;

  int? selectedLandId;

  void selectLand(LandModel land) {
    _selectedLand = land;
    selectedLandId = land.id;
    notifyListeners();
  }

  void deselectLand() {
    selectedLandId = null;
    notifyListeners();
  }

  void resetFields() {
    farmNameController.clear();
    surveyNoController.clear();
    hissaNoController.clear();
    farmSizeController.clear();
    selectedLandId = null;
    notifyListeners();
  }
  // -------------------------------------------------------
  // CREATE LAND
  // -------------------------------------------------------
  Future<bool> saveLandDetails({
    required String district,
    required String taluk,
    required String village,
    required String panchayat,
  }) async {
    isSaving = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("uid");

    if (userId == null) {
      isSaving = false;
      notifyListeners();
      return false;
    }


    final url = Uri.parse(ApiConstants.createLand);

    final body = {
      "user_id": int.parse(userId),
      "land_name": farmNameController.text.trim(),
      "district": district,
      "taluk": taluk,
      "village": village,
      "panchayat": panchayat,
      "survey_no": surveyNoController.text.trim(),
      "hissa_no": hissaNoController.text.trim(),
      "farm_size": farmSizeController.text.trim(),
    };



    isSaving = false;
    notifyListeners();

    try {
      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
print('land savce');
print(res.statusCode);
print(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      } else {
        final body = jsonDecode(res.body);
        errorMessage = body['message'] ?? 'Something went wrong';
        return false;
      }
    } catch (e) {
      errorMessage = 'Unable to save land. Please try again.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }

    return false;
  }

  // -------------------------------------------------------
  // GET LANDS BY USER ID
  // -------------------------------------------------------
  Future<void> fetchLandsByUser() async {
    isLoadingList = true;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString("uid");

    if (userId == null) {
      isLoadingList = false;
      notifyListeners();
      return;
    }

    final url = Uri.parse("${ApiConstants.getLandsByUser}/$userId");
    final res = await http.get(url);

    if (res.statusCode == 200) {
      List data = jsonDecode(res.body);
      _lands = data.map((e) => LandModel.fromJson(e)).toList();
    }

    isLoadingList = false;
    notifyListeners();
  }

  // -------------------------------------------------------
  // GET PARTICULAR LAND DETAILS
  // -------------------------------------------------------
  Future<void> fetchLandById(int landId) async {
    final url = Uri.parse("${ApiConstants.getLandById}/$landId");

    final res = await http.get(url);

    if (res.statusCode == 200) {
      _selectedLand = LandModel.fromJson(jsonDecode(res.body));

      // Prefill UI controllers for edit screens
      farmNameController.text = _selectedLand?.landName ?? "";
      panchayatController.text = _selectedLand?.panchayat ?? "";
      surveyNoController.text = _selectedLand?.surveyNo ?? "";
      hissaNoController.text = _selectedLand?.hissaNo ?? "";
      farmSizeController.text = _selectedLand?.farmSize.toString() ?? "";
    }

    notifyListeners();
  }

  // -------------------------------------------------------
  // UPDATE LAND DETAILS
  // -------------------------------------------------------
  Future<bool> updateLand(int landId,String? panchayat) async {
    final url = Uri.parse("${ApiConstants.updateLand}/$landId");

    final body = {
      "land_name": farmNameController.text.trim(),
      "panchayat": panchayat,
      "survey_no": surveyNoController.text.trim(),
      "hissa_no": hissaNoController.text.trim(),
      "farm_size": farmSizeController.text.trim(),
    };

    try {

      final res = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );


      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      } else {
        final body = jsonDecode(res.body);
        errorMessage = body['message'] ?? 'Something went wrong';
        return false;
      }
    } catch (e) {
      errorMessage = 'Unable to save land. Please try again.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // -------------------------------------------------------
  // DELETE LAND
  // -------------------------------------------------------
  Future<bool> deleteLand(int landId) async {
    final url = Uri.parse("${ApiConstants.deleteLand}/$landId");

    final res = await http.delete(url);

    if (res.statusCode == 200) {
      _lands.removeWhere((e) => e.id == landId);
      notifyListeners();
      return true;
    }
    return false;
  }
}
