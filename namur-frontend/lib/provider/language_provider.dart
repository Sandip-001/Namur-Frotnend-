import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en', 'US');

  Locale get currentLocale => _currentLocale;

  void changeLanguage(BuildContext context, Locale newLocale) {
    _currentLocale = newLocale;
    context.setLocale(newLocale); // ✅ This updates the app instantly
    notifyListeners();
  }
}
