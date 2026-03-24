import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_namur_frontend/screens/login_screen.dart';


class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  static const _languages = <Map<String, dynamic>>[
    {'label': 'English', 'locale': Locale('en', 'US'), 'color': Colors.pinkAccent},
    {'label': 'தமிழ்', 'locale': Locale('ta', 'IN'), 'color': Colors.redAccent},
    {'label': 'ಕನ್ನಡ', 'locale': Locale('kn', 'IN'), 'color': Colors.orangeAccent},
    {'label': 'हिंदी', 'locale': Locale('hi', 'IN'), 'color': Colors.greenAccent},
    {'label': 'తెలుగు', 'locale': Locale('te', 'IN'), 'color': Colors.blueAccent},
    {'label': 'മലയാളം', 'locale': Locale('ml', 'IN'), 'color': Colors.tealAccent},
    {'label': 'मराठी', 'locale': Locale('mr', 'IN'), 'color': Colors.amberAccent},
    {'label': 'বাংলা', 'locale': Locale('bn', 'IN'), 'color': Colors.limeAccent},
  ];

  @override
  Widget build(BuildContext context) {
    final current = context.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text('select_language').tr(),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _languages.map((lang) {
            final Locale locale = lang['locale'] as Locale;
            final bool isSelected = locale.languageCode == current.languageCode;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: GestureDetector(
                onTap: () async {
                  await context.setLocale(locale);

                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString('saved_locale', '${locale.languageCode}_${locale.countryCode}');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'language_changed'.tr(),

                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: lang['color'] as Color,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: Colors.green, width: 2) : null,
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      )
                    ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      lang['label'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.green[900] : Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
