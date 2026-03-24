// lib/provider/details_expand_provider.dart
import 'package:flutter/material.dart';

class DetailsExpandProvider extends ChangeNotifier {
  // Track expanded sections
  bool locationExpanded = false;
  bool kycExpanded = false;
  bool farmExpanded = false;
  bool machinaryExpanded = false;
  bool cropsExpanded = false;
  bool animalsExpanded = false;

  bool landSizeExpanded = false;
  bool cropDetailExpanded = false;
  bool implementExpanded = false;
  bool dateTimeExpanded = false;
  bool contactExpanded = false;
  bool animalExpanded = false;

  bool landAreaExpanded = true;
  bool cropExpanded = false;

  bool dateExpanded = false;



  void toggle(String section) {
    switch (section) {
      case 'location':
        locationExpanded = !locationExpanded;
        break;
      case 'kyc':
        kycExpanded = !kycExpanded;
        break;
      case 'farm':
        farmExpanded = !farmExpanded;
        break;
      case 'machinary':
        machinaryExpanded = !machinaryExpanded;
        break;
      case 'crops':
        cropsExpanded = !cropsExpanded;
        break;
      case 'animals':
        animalsExpanded = !animalsExpanded;
        break;
      case 'landSize':
        landSizeExpanded = !landSizeExpanded;
        break;
      case 'cropDetail':
        cropDetailExpanded = !cropDetailExpanded;
        break;
      case 'implement':
        implementExpanded = !implementExpanded;
        break;
      case 'dateTime':
        dateTimeExpanded = !dateTimeExpanded;
        break;
      case 'contact':
        contactExpanded = !contactExpanded;
        break;
      case 'landArea':
        landAreaExpanded = !landAreaExpanded;
        break;
      case 'crop':
        cropExpanded = !cropExpanded;
        break;
      case 'date':
        dateExpanded = !dateExpanded;
        break;
      case 'animal':
        animalExpanded = !animalExpanded;
        break;
    }
    notifyListeners();
  }

  // lib/provider/land_expand_providter.dart


}
