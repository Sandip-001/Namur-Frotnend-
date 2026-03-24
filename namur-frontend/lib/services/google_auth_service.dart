import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../utils/api_url.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '581813390000-cockp1hrdsac5h8b9k9ceas7bqe5p4tj.apps.googleusercontent.com' : null,
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GOOGLE LOGIN + FIREBASE LOGIN
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);
        print(userCredential.user);
      return userCredential.user;
    } catch (e) {
      print("Google Login Error: $e");
      return null;
    }
  }

  // BACKEND LOGIN
  Future<Map<String, dynamic>?> loginToBackend(User user) async {
    final url = Uri.parse(ApiConstants.loginWithGoogle);

    // Google profile image URL
    String? photoUrl = user.photoURL;

    // If user has no photo → send empty string instead of null
    if (photoUrl == null || photoUrl.isEmpty) {
      photoUrl = "";
    }

    final body = {
      "firebase_uid": user.uid,
      "email": user.email ?? "",
      "username": user.displayName ?? "",
      "profile_image_url": photoUrl,   // <-- Added here
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
print('login backend');
print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print("API Error: $e");
      return null;
    }
  }
}
