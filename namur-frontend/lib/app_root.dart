import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'models/machinery_ad_model.dart';
import 'models/othersad_model.dart';
import 'screens/machinery_description_screen.dart';
import 'screens/other_description_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'utils/navigation_service.dart';

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;

  bool _checkingInitialLink = true;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  // ---------------- INIT DEEP LINKS ----------------

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // App opened from terminated state
    final Uri? initialUri = await _appLinks.getInitialAppLink();
    if (initialUri != null) {
      _handleUri(initialUri);
    }

    // App opened from background
    _linkSub = _appLinks.uriLinkStream.listen(
          (uri) => _handleUri(uri),
      onError: (err) => debugPrint("❌ Deep link error: $err"),
    );

    setState(() {
      _checkingInitialLink = false;
    });
  }

  // ---------------- HANDLE URI ----------------

  Future<void> _handleUri(Uri uri) async {
    debugPrint("📥 Deep link received: $uri");

    final segments = uri.pathSegments;
    if (segments.length < 2 || segments.first != 'ad') return;

    final adUid = segments[1];
    debugPrint("🔥 Ad UID: $adUid");

    final prefs = await SharedPreferences.getInstance();
    final district = prefs.getString("district") ?? "";

    await _openAd(adUid, district);
  }

  // ---------------- FETCH + NAVIGATE ----------------

  Future<void> _openAd(String adUid, String district) async {
    final apiUri = Uri.parse(
      "https://api.inkaanalysis.com/api/adShare/ad/$adUid",
    ).replace(
      queryParameters: {"district": district},
    );

    try {
      final response = await http.get(apiUri);
      if (response.statusCode != 200) {
        _showError("Server error (${response.statusCode})");
        return;
      }

      final data = jsonDecode(response.body);
      final adData = data["ad"];
      if (adData == null) {
        _showError("Ad not available");
        return;
      }

      final category =
      (adData["category_name"] ?? "").toString().toLowerCase();

      // ✅ 1️⃣ Always reset stack to HOME first
      Navigator.pushAndRemoveUntil(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
            (_) => false,
      );

      // ✅ 2️⃣ Push correct ad screen on top
      Future.microtask(() {
        if (category == "machinery") {
          final ad = MachineryAdModel.fromJson(adData);
          Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (_) =>
                  MachineryDescriptionScreen(ad: ad, isBooking: false),
            ),
          );
        } else {
          final ad = OtherAdModel.fromJson(adData);
          Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (_) => OtherDescriptionScreen(ad: ad),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint("❌ Deep link error: $e");
      _showError("Something went wrong");
    }
  }

  // ---------------- UI HELPERS ----------------

  void _showError(String message) {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  // ---------------- ROOT ----------------

  @override
  Widget build(BuildContext context) {
    if (_checkingInitialLink) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 🚀 Normal app launch
    return const SplashScreen();
  }
}