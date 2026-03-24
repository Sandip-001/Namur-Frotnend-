import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/api_url.dart';

class LandDistrictProvider with ChangeNotifier {
  // ---------------------------------------------------------
  // JSON Data: District → Taluk → Village
  // ---------------------------------------------------------
  Map<String, dynamic> _fullJson = {};

  // Dropdown Data
  List<String> _districts = [];
  List<String> _taluks = [];
  List<String> _villages = [];
  List<String> _panchayats = [];

  // Selected Values
  String? _selectedDistrict;
  String? _selectedTaluk;
  String? _selectedVillage;
  String? _selectedPanchayat;

  // Controllers
  final TextEditingController panchayatController = TextEditingController();

  // Getters
  List<String> get districts => _districts;
  List<String> get taluks => _taluks;
  List<String> get villages => _villages;
  List<String> get panchayats => _panchayats;
  String? get selectedDistrict => _selectedDistrict;
  String? get selectedTaluk => _selectedTaluk;
  String? get selectedVillage => _selectedVillage;
  String? get selectedPanchayat => _selectedPanchayat;

  // ---------------------------------------------------------
  // Reset Fields
  // ---------------------------------------------------------
  void resetFields() {
    _selectedDistrict = null;
    _selectedTaluk = null;
    _selectedVillage = null;
    _selectedPanchayat = null;
    _taluks = [];
    _villages = [];
    _panchayats = [];
    panchayatController.clear();
    notifyListeners();
  }

  // 🔥 Helper to capitalize each word in a string (Sentence Case)
  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // ---------------------------------------------------------
  // Load District List from JSON
  // ---------------------------------------------------------
  Future<void> loadDistricts() async {
    final jsonString = await rootBundle.loadString(
      "assets/json/karnataka_districts_taluks_villages.json",
    );
    _fullJson = json.decode(jsonString);
    _districts = _fullJson.keys.map((d) => _capitalize(d)).toList();
    notifyListeners();
  }

  // ---------------------------------------------------------
  // Select District → Load Taluks
  // ---------------------------------------------------------
  List<String> setDistrict(
    String value, {
    String? prefillTaluk,
    String? prefillVillage,
    String? prefillPanchayat,
  }) {
    _selectedDistrict = value;

    // Reset dependent dropdowns
    _selectedTaluk = null;
    _selectedVillage = null;
    _selectedPanchayat = null;

    // Find original key for lookup
    final originalDistrictKey = _fullJson.keys.firstWhere(
      (k) => k.trim().toLowerCase() == value.trim().toLowerCase(),
      orElse: () => value,
    );

    _selectedDistrict = _districts.firstWhere(
      (d) => d.trim().toLowerCase() == value.trim().toLowerCase(),
      orElse: () => _capitalize(originalDistrictKey),
    );

    final districtData = _fullJson[originalDistrictKey] as Map<String, dynamic>;
    _taluks = districtData.keys.map((t) => _capitalize(t)).toList();
    _villages = [];
    _panchayats = [];

    // Prefill Taluk → Village → Panchayat if provided
    if (prefillTaluk != null) {
      setTaluk(
        prefillTaluk,
        prefillVillage: prefillVillage,
        prefillPanchayat: prefillPanchayat,
      );
    }

    notifyListeners();
    return _taluks;
  }

  // ---------------------------------------------------------
  // Select Taluk → Load Villages and Panchayats
  // ---------------------------------------------------------
  List<String> setTaluk(
    String value, {
    String? prefillVillage,
    String? prefillPanchayat,
  }) {
    _selectedTaluk = _taluks.firstWhere(
      (t) => t.toLowerCase() == value.toLowerCase(),
      orElse: () => value,
    );

    final originalDistrictKey = _fullJson.keys.firstWhere(
      (k) => k.trim().toLowerCase() == (_selectedDistrict ?? "").trim().toLowerCase(),
      orElse: () => _selectedDistrict ?? "",
    );
    final districtData = _fullJson[originalDistrictKey] as Map<String, dynamic>;

    final originalTalukKey = districtData.keys.firstWhere(
      (k) => k.trim().toLowerCase() == value.trim().toLowerCase(),
      orElse: () => value,
    );

    final talukData = districtData[originalTalukKey];

    // Load villages
    if (talukData is Map) {
      _villages = talukData.keys.map((v) => _capitalize(v.toString())).toList();
    } else if (talukData is List) {
      _villages = talukData.map((v) => _capitalize(v.toString())).toList();
    } else {
      _villages = [];
    }

    // Reset selected village/panchayat
    _selectedVillage = null;
    _selectedPanchayat = null;
    _panchayats = [];

    // Prefill village & panchayat
    if (prefillVillage != null) {
      try {
        _selectedVillage = _villages.firstWhere(
          (v) => v.trim().toLowerCase() == prefillVillage.trim().toLowerCase(),
        );
      } catch (_) {
        // If missing from JSON, add it so dropdown can show it
        final capitalized = _capitalize(prefillVillage);
        if (!_villages.contains(capitalized)) _villages.add(capitalized);
        _selectedVillage = capitalized;
      }

      // Load panchayats for this village
      if (talukData is Map) {
        // Get entries and find matching one
        MapEntry? foundEntry;
        for (var entry in talukData.entries) {
          if (entry.key.toString().trim().toLowerCase() == prefillVillage.trim().toLowerCase()) {
            foundEntry = entry;
            break;
          }
        }
        
        final villageData = foundEntry?.value;
        if (villageData is List) {
          _panchayats = villageData.map((p) => _capitalize(p.toString())).toList();
        } else {
          _panchayats = List<String>.from(_villages);
        }
      } else {
        _panchayats = List<String>.from(_villages);
      }
    }

    // Prefill Panchayat
    if (prefillPanchayat != null) {
      try {
        _selectedPanchayat = _panchayats.firstWhere(
          (p) => p.trim().toLowerCase() == prefillPanchayat.trim().toLowerCase(),
        );
      } catch (_) {
        // If missing from JSON, add it so dropdown can show it
        final capitalized = _capitalize(prefillPanchayat);
        if (!_panchayats.contains(capitalized)) _panchayats.add(capitalized);
        _selectedPanchayat = capitalized;
      }
    }

    notifyListeners();
    return _villages;
  }

  // ---------------------------------------------------------
  // Select Village
  // ---------------------------------------------------------
  void setVillage(String value) {
    _selectedVillage = value;

    // Load Panchayats (same as villages)
    _panchayats = List<String>.from(_villages);

    if (!_panchayats.contains(_selectedPanchayat)) {
      _selectedPanchayat = null;
    }

    notifyListeners();
  }

  // ---------------------------------------------------------
  // Select Panchayat
  // ---------------------------------------------------------
  void setPanchayat(String value) {
    _selectedPanchayat = value;
    notifyListeners();
  }

  // ---------------------------------------------------------
  // Save Land Details API (example)
  // ---------------------------------------------------------
  Future<bool> saveLandDetails({required String landSize}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString("firebase_uid");
    if (uid == null) return false;

    final url = Uri.parse(ApiConstants.saveLandDetails);

    final body = {
      "firebase_uid": uid,
      "district": _selectedDistrict,
      "taluk": _selectedTaluk,
      "village": _selectedVillage,
      "panchayat": _selectedPanchayat,
      "land_size": landSize,
    };

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    return response.statusCode == 200;
  }
}
