import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/create_ad_model.dart';

class DetailsProvider with ChangeNotifier {
  String? selectedA;
  String? selectedB;
  String? selectedC;
  String? selectedD;
  String? selectedE;
  String? price;
  String? description;

  List<File> images = []; // NEWLY PICKED IMAGES
  List<AdImage> existingImages = []; // OLD IMAGES FROM API (WITH publicId, url)

  final ImagePicker _picker = ImagePicker();

  // ------------------------ DROPDOWN SETTERS ------------------------

  void setA(String value) {
    selectedA = value;
    notifyListeners();
  }

  void setB(String value) {
    selectedB = value;
    notifyListeners();
  }

  void setC(String value) {
    selectedC = value;
    notifyListeners();
  }

  void setD(String value) {
    selectedD = value;
    notifyListeners();
  }

  void setE(String value) {
    selectedE = value;
    notifyListeners();
  }

  void setPrice(String value) {
    price = value;
    notifyListeners();
  }

  void setDescription(String value) {
    description = value;
    notifyListeners();
  }

  List<String> getExistingImageUrls() {
    return existingImages.map((img) => img.url ?? "").toList();
  }
  // ------------------------ IMAGE METHODS ------------------------

  /// PREFILL existing Cloudinary images
  void setExistingImages(List<AdImage> imgs) {
    existingImages = imgs;
    notifyListeners();
  }

  /// USER PICKS NEW IMAGES (FILES)
  Future<void> pickImages(BuildContext context) async {
    final List<XFile> picked = await _picker.pickMultiImage();

    if (picked.isEmpty) return;

    final totalExisting = images.length + existingImages.length;

    // If user selects more than remaining allowed images, show warning and return
    if (picked.length + totalExisting > 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 1000),
          content: Text(
            "You can select up to 6 images only. Please select fewer images.",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return; // Do not add any images
    }

    // Add picked images if within limit
    images.addAll(picked.map((e) => File(e.path)).toList());
    notifyListeners();
  }

  /// REMOVE an EXISTING IMAGE
  void removeExistingImage(int index) {
    existingImages.removeAt(index);
    notifyListeners();
  }

  /// REMOVE a newly added FILE IMAGE
  void removeNewImage(int index) {
    images.removeAt(index);
    notifyListeners();
  }

  void clearAllImages() {
    images.clear();
    existingImages.clear();
    notifyListeners();
  }

  void resetDetails() {
    images.clear();
    selectedC = null;
    notifyListeners();
  }

  void resetAll() {
    images.clear();
    existingImages.clear();
    selectedA = null;
    selectedB = null;
    selectedC = null;
    price = null;
    description = null;
    notifyListeners();
  }
}
