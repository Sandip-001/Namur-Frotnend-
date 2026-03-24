import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:provider/provider.dart';

import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/login_address_screen.dart'; // 🔥 Import AddressScreen
import '../provider/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  final String? sharedAdId;
  final String? sharedDistrict;

  const SplashScreen({super.key, this.sharedAdId, this.sharedDistrict});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _hasInternet = true;
  bool _navigationDone = false; // 🔒 VERY IMPORTANT

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _startFlow();
  }

  // ---------------- FLOW ----------------

  Future<void> _startFlow() async {
    // Let splash render
    await Future.delayed(const Duration(milliseconds: 400));

    // 1️⃣ Internet check
    final hasInternet = await _hasInternetConnection();
    if (!hasInternet) {
      if (mounted) {
        setState(() => _hasInternet = false);
      }
      return;
    }

    // 2️⃣ Splash delay
    await Future.delayed(const Duration(seconds: 2));

    // 3️⃣ Login check & navigation
    await _checkLogin();
  }

  // ---------------- INTERNET ----------------

  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    // connectivity_plus >= 6.0 returns List<ConnectivityResult>
    bool isNone = !connectivityResult.any(
      (result) => result != ConnectivityResult.none,
    );

    if (isNone) return false;

    // InternetAddress.lookup is from dart:io and throws UnsupportedError on web
    if (kIsWeb) return true;

    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _retry() async {
    setState(() => _hasInternet = true);
    await _startFlow();
  }

  // ---------------- LOGIN + NAV ----------------

  Future<void> _checkLogin() async {
    if (_navigationDone) return;
    _navigationDone = true;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.checkLoginStatus(context);

    if (!mounted) return;

    if (isLoggedIn) {
      if (authProvider.isFirstTime) {
        // 🔥 Redirect to AddressScreen if profile is incomplete
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AddressScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              sharedAdId: widget.sharedAdId,
              sharedDistrict: widget.sharedDistrict,
            ),
          ),
        );
      }
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  // ---------------- ANIMATION ----------------

  void _initAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _hasInternet
          ? FadeTransition(opacity: _animation, child: _buildSplashContent())
          : _buildNoInternetUI(),
    );
  }

  Widget _buildSplashContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/splash_logo.png', width: 150),
          const SizedBox(height: 12),
          Image.asset('assets/images/splash_name.png'),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: const Color(0xFF99D663),
            child: const Column(
              children: [
                Text(
                  "Namur",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Farming future...",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoInternetUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text(
            "No network connection",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Please check your connection and try again",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
