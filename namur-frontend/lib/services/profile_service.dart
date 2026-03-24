import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../utils/api_url.dart';

class ProfileService {
  /// UPLOAD PROFILE IMAGE
  Future<Map<String, dynamic>?> uploadProfileImage(File imageFile) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString("firebase_uid");

      if (uid == null) {
        print("UID is NULL");
        return null;
      }

      final url = Uri.parse(ApiConstants.uploadProfile);

      // Multipart request
      var request = http.MultipartRequest("POST", url);

      request.fields['firebase_uid'] = uid;

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print(response.statusCode);
        print("Upload Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Upload Error: $e");
      return null;
    }
  }

  // 🔹 FETCH PROFILE DETAILS BY FIREBASE UID
  Future<AuthUser?> fetchProfileDetails() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString("firebase_uid");

      if (uid == null) {
        print("UID is NULL");
        return null;
      }

      final url = Uri.parse("${ApiConstants.getUserByFirebase}/$uid");

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return AuthUser.fromJson(jsonData);
      } else {
        print("Fetch Failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Fetch Error: $e");
      return null;
    }
  }
}
