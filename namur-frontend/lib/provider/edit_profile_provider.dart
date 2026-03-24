import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ProfileProvider extends ChangeNotifier {
  String name = '';
  String phone = '';
  String email = '';
  String state = '';
  String district = '';
  String village = '';
  String aadhar = '';
  String pan = '';
  String landSelected = '';
  String landSize = '';
  XFile? profileImage;

  Future<void> pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImage = picked;
      notifyListeners();
    }
  }

  void updateField(String field, String value) {
    switch (field) {
      case 'name':
        name = value;
        break;
      case 'phone':
        phone = value;
        break;
      case 'email':
        email = value;
        break;
      case 'state':
        state = value;
        break;
      case 'district':
        district = value;
        break;
      case 'village':
        village = value;
        break;
      case 'aadhar':
        aadhar = value;
        break;
      case 'pan':
        pan = value;
        break;
      case 'landSelected':
        landSelected = value;
        break;
      case 'landSize':
        landSize = value;
        break;
    }
    notifyListeners();
  }

  void saveProfile() {
    if (kDebugMode) {
      print('Profile Saved: $name, $phone, $email, $state');
    }
  }

  bool addressExpanded = true;
  bool kycExpanded = false;
  bool landExpanded = false;
  bool cropExpanded = false;
  bool machineryExpanded = false;
  bool animalsExpanded = false;

  void toggle(String section) {
  switch (section) {
  case 'address':
  addressExpanded = !addressExpanded;
  break;
  case 'kyc':
  kycExpanded = !kycExpanded;
  break;
  case 'land':
  landExpanded = !landExpanded;
  break;
  case 'crop':
  cropExpanded = !cropExpanded;
  break;
  case 'machinery':
  machineryExpanded = !machineryExpanded;
  break;
  case 'animals':
  animalsExpanded = !animalsExpanded;
  break;
  }
  notifyListeners();
  }


}
