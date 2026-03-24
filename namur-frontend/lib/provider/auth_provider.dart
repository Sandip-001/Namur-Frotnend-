import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../utils/api_url.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/google_auth_service.dart';

enum DeleteAccountResult { success, requiresReLogin, failure }

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoggedIn = false;
  bool _isFirstTime = false; // 🔥 Track onboarding status
  String? _uid;
  String? _name;
  String? _email;

  bool get isLoggedIn => _isLoggedIn;
  bool get isFirstTime => _isFirstTime; // 🔥 Getter for splash screen
  String? get uid => _uid;
  String? get name => _name;
  String? get email => _email;
  Future<bool> checkLoginStatus(BuildContext context) async {
    // debugSnack(context, "🟡 checkLoginStatus START");

    final prefs = await SharedPreferences.getInstance();

    final localLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    // debugSnack(context, "📦 Local isLoggedIn = $localLoggedIn");

    if (!localLoggedIn) {
      _isLoggedIn = false;
      notifyListeners();
      return false;
    }

    // debugSnack(context, "⏳ Waiting for Firebase (non-blocking)");

    // 🔹 Just TRY Firebase, don't punish user
    try {
      await FirebaseAuth.instance.authStateChanges().first.timeout(
        const Duration(seconds: 3),
      );
    } catch (_) {
      // debugSnack(context, "⚠️ Firebase slow, continuing with backend session");
    }

    //debugSnack(context, "🔥 Firebase user = ${FirebaseAuth.instance.currentUser?.uid ?? 'NULL'}");

    // 🔹 RESTORE BACKEND SESSION REGARDLESS
    _uid = prefs.getString("uid");
    _email = prefs.getString("email");
    _name = prefs.getString("username");
    _isFirstTime = prefs.getBool("isFirstTime") ?? false; // 🔥 Check if details needed

    _isLoggedIn = true;
    notifyListeners();

    //debugSnack(context, "🟢 LOGIN RESTORED (backend-driven)");
    return true;
  }

  /// GOOGLE LOGIN
  Future<bool> signInWithGoogle() async {
    try {
      final googleAuthService = GoogleAuthService();
      final user = await googleAuthService.signInWithGoogle();

      if (user == null) return false;

      final loginResponse = await loginToBackend(user);

      if (loginResponse != null) {
        return true;
      }

      return false;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return false;
    }
  }

  /// BACKEND LOGIN
  Future<LoginResponse?> loginToBackend(User user) async {
    final url = Uri.parse(ApiConstants.loginWithGoogle);

    final body = {
      "firebase_uid": user.uid,
      "email": user.email ?? "",
      "username": user.displayName ?? "",
      "profile_image_url": user.photoURL ?? "",
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(jsonData);
        final loginUser = loginResponse.user;

        final prefs = await SharedPreferences.getInstance();

        /// 🔐 SAVE USER DATA
        await prefs.setString("firebase_uid", loginUser?.firebaseUid ?? "");
        await prefs.setString("uid", loginUser?.id.toString() ?? "");
        await prefs.setString("email", loginUser?.email ?? "");
        await prefs.setString("username", loginUser?.username ?? "");
        await prefs.setString("mobile", loginUser?.mobile ?? "");
        await prefs.setString("district", loginUser?.district ?? "");
        await prefs.setString("profession", loginUser?.profession ?? "");
        await prefs.setString(
          "profile_image_url",
          loginUser?.profileImageUrl ?? "",
        );

        /// 🔥 FIRST TIME CHECK
        final isFirstTime =
            (loginUser?.mobile == null || loginUser!.mobile!.isEmpty) &&
            (loginUser?.district == null || loginUser!.district!.isEmpty);

        await prefs.setBool("isFirstTime", isFirstTime);

        /// 🔥 LOGIN STATE
        await prefs.setBool("isLoggedIn", true);
        await prefs.setString("token", jsonData["token"] ?? "");

        /// ✅ RESTORE PROVIDER STATE (CRITICAL FIX)
        _isLoggedIn = true;
        _isFirstTime = isFirstTime; // 🔥 Set status
        _uid = loginUser?.id.toString();
        _email = loginUser?.email;
        _name = loginUser?.username;

        notifyListeners();

        return loginResponse;
      }

      return null;
    } catch (e) {
      print("❌ API Error: $e");
      return null;
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.remove("isLoggedIn");

    _isLoggedIn = false;
    _uid = null;
    _name = null;
    _email = null;

    notifyListeners();
  }

  ///OTP VERIFY
  Future<bool> verifyOtp(String otp) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uid = prefs.getString("firebase_uid");

    if (uid == null) return false;

    final url = Uri.parse(ApiConstants.verifyOtp);

    final body = {"firebase_uid": uid, "otp": otp};

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        /// Convert to model
        final loginResponse = LoginResponse.fromJson(jsonData);

        /// Check success message
        if (loginResponse.message == "OTP Verified") {
          return true;
        }
      }

      return false; // failure case
    } catch (e) {
      print("Verify OTP Error: $e");
      return false;
    }
  }

  /// SAVE FCM TOKEN TO BACKEND
  Future<bool> saveFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? uid = prefs.getString("uid");

      if (uid == null) {
        print("❌ No UID found. Cannot save FCM token.");
        return false;
      }

      // 🔥 Get actual FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        print("❌ FCM Token is NULL");
        return false;
      }

      print("🔥 Sending FCM TOKEN to server: $fcmToken");

      final url = Uri.parse(ApiConstants.saveToken);

      final body = {"user_id": int.parse(uid), "fcm_token": fcmToken};

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("📩 Save Token Response: ${response.statusCode}");
      print("📩 Body: ${response.body}");

      return response.statusCode == 200;
    } catch (e) {
      print("❌ Save FCM Token Error: $e");
      return false;
    }
  }

  /// 🔥 DELETE ACCOUNT (WITH BODY)
  /// 🔥 DELETE ACCOUNT (ENUM BASED)
  Future<DeleteAccountResult> deleteAccount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final firebaseUid =
          (prefs.getString("firebase_uid") ?? FirebaseAuth.instance.currentUser?.uid ?? "")
              .trim();

      if (firebaseUid.isEmpty) {
        debugPrint("Delete Account: firebase_uid is empty");
        return DeleteAccountResult.failure;
      }

      final url = Uri.parse("${ApiConstants.deleteUser}/$firebaseUid");

      final response = await http.delete(url);

      print("🗑️ Delete Response Status: ${response.statusCode}");
      if (response.body.isNotEmpty) {
        print("🗑️ Delete Response Body: ${response.body}");
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        /// 🔥 FIREBASE DELETE (NON-BLOCKING & SAFE)
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            user.delete().timeout(const Duration(seconds: 3)).catchError((e) {
              debugPrint("⚠️ Firebase delete skipped: $e");
            });
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'requires-recent-login') {
            return DeleteAccountResult.requiresReLogin;
          }
        } catch (_) {
          // ignore firebase errors
        }

        /// 🔥 ALWAYS CLEAR LOCAL SESSION
        await _googleSignIn.signOut();
        await _auth.signOut();
        await prefs.clear();

        _isLoggedIn = false;
        _uid = null;
        _name = null;
        _email = null;

        notifyListeners();
        print('account deleted success');
        print(DeleteAccountResult.success.name);
        return DeleteAccountResult.success;
      }

      return DeleteAccountResult.failure;
    } catch (e) {
      debugPrint("❌ Delete Account Error: $e");
      return DeleteAccountResult.failure;
    }
  }

  /// 🔹 Show user-friendly re-login dialog
}
