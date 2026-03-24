import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../provider/auth_provider.dart';
import 'home_screen.dart';
import 'login_address_screen.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    // connectivity_plus >= 6.0 returns List<ConnectivityResult>
    bool isNone = !connectivityResult.any(
      (result) => result != ConnectivityResult.none,
    );

    if (isNone) return false;

    if (kIsWeb) return true;

    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _checkInternetDialog() async {
    final hasInternet = await _hasInternetConnection();

    if (!hasInternet && mounted) {
      bool isConnected = false;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: const Text("No Internet"),
            content: const Text("Please check your connection and try again."),
            actions: [
              TextButton(
                onPressed: () async {
                  final connected = await _hasInternetConnection();
                  if (connected) {
                    isConnected = true;
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Still no internet connection"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text("Retry"),
              ),
            ],
          );
        },
      );

      return isConnected;
    }

    return hasInternet;
  }

  Future<void> handleGoogleLogin() async {
    // ✅ Check internet first
    final internetAvailable = await _checkInternetDialog();
    if (!internetAvailable) return; // stop if no internet

    setState(() => _isLoading = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    bool success = await auth.signInWithGoogle();

    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('google_login_failed'.tr())));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool("isFirstTime") ?? true;

    if (isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AddressScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/farm_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 15),
              Column(
                children: [
                  Text(
                    'app_name_native'.tr(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E7A3F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Namur',
                    style: GoogleFonts.agbalumo(
                      textStyle: const TextStyle(
                        color: Color(0xFF1E7A3F),
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black26,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/app_logo_big.png',
                    width: 100,
                    height: 100,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical: 8,
                ),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : handleGoogleLogin,
                  icon: Image.asset(
                    'assets/icons/google.png',
                    height: 24,
                    width: 24,
                  ),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Signin with google',
                          style: TextStyle(color: Colors.black87),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Farmers market place',
                style: GoogleFonts.preahvihear(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    letterSpacing: .5,
                  ),
                ),
              ),
              const SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}
