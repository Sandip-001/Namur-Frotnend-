import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:the_namur_frontend/Widgets/custom_appbar.dart';
import 'package:the_namur_frontend/Widgets/drawer_menu.dart';

import '../utils/app_state.dart';
import 'home_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  final List<String> langs = const [
    'ಕನ್ನಡ',
    'English',
    'தமிழ்',
    'తెలుగు',
    'മലയാളം',
    'हिंदी',
    'বাংলা',
    'मराठी',
  ];

  final List<Color> colors = const [
    Color(0xFFFFCDD2), // Kannada - light red
    Color(0xFFBBDEFB), // English - light blue
    Color(0xFFC8E6C9), // Tamil - light green
    Color(0xFFFFF9C4), // Telugu - light yellow
    Color(0xFFD1C4E9), // Malayalam - light purple
    Color(0xFFFFE0B2), // Hindi - light orange
    Color(0xFFB2DFDB), // Bengali - teal
    Color(0xFFF8BBD0), // Marathi - pink
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Select Your Language', showBack: true),
      drawer: DrawerMenu(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth * 0.95,
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  // 🔹 increased spacing between tiles
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 24,
                  // 🔹 increased height of each tile
                  childAspectRatio: 2.3,
                  children: List.generate(
                    langs.length,
                    (index) => LanguageTile(
                      lang: langs[index],
                      bgColor: colors[index % colors.length],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LanguageTile extends StatelessWidget {
  final String lang;
  final Color bgColor;

  const LanguageTile({super.key, required this.lang, required this.bgColor});

  Locale _getLocaleForLanguage(String lang) {
    switch (lang) {
      case 'English':
        return const Locale('en', 'US');
      case 'தமிழ்':
        return const Locale('ta', 'IN');
      case 'ಕನ್ನಡ':
        return const Locale('kn', 'IN');
      case 'हिंदी':
        return const Locale('hi', 'IN');
      case 'తెలుగు':
        return const Locale('te', 'IN');
      case 'മലയാളം':
        return const Locale('ml', 'IN');
      case 'मराठी':
        return const Locale('mr', 'IN');
      case 'বাংলা':
        return const Locale('bn', 'IN');
      default:
        return const Locale('en', 'US');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final selected = state.language == lang;

    return GestureDetector(
      onTap: () {
        final state = Provider.of<AppState>(context, listen: false);
        state.setLanguage(lang);

        final locale = _getLocaleForLanguage(lang);
        context.setLocale(locale);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      },
      child: Stack(
        children: [
          // ------------------ MAIN TILE ------------------
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            decoration: BoxDecoration(
              color: selected ? Colors.green[300] : bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? Colors.green.shade700 : Colors.transparent,
                width: selected ? 3 : 0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: selected ? 6 : 3,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                lang,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),

          // ------------------ TICK ICON ------------------
          if (selected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                padding: const EdgeInsets.all(3),
                child: const Icon(Icons.check, color: Colors.green, size: 20),
              ),
            ),
        ],
      ),
    );
  }
}
