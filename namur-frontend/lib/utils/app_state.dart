// app_state.dart
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String language = 'English';
  String mobile = '';
  String district = '';
  String profession = '';
  String age = '';
  String otp = '';

  void setLanguage(String l) {
    language = l;
    notifyListeners();
  }

  void setAddress({String? mobile, String? district, String? profession, String? age}) {
    if (mobile != null) this.mobile = mobile;
    if (district != null) this.district = district;
    if (profession != null) this.profession = profession;
    if (age != null) this.age = age;
    notifyListeners();}

  void setOtp(String o) {
    otp = o;
    notifyListeners();
  }
}
