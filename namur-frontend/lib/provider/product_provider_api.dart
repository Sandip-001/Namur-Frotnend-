import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/product_model_api.dart';
import '../utils/api_url.dart';

class ProductProvider with ChangeNotifier {
  bool isLoading = false;

  List<ProductModel> cropList = [];
  List<ProductModel> machineryList = [];
  List<ProductModel> animalList = [];

  // Selected values (ID)
  int? selectedCropId;
  int? selectedMachineryId;
  int? selectedAnimalId;

  // Fetch function (common)
  Future<void> fetchProductsByCategory(String category) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      "${ApiConstants.getProductsByCategory}?categoryName=$category",
    );
    final res = await http.get(url);
    print('fetch product by category');
    print(res.statusCode);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body)["products"];
      List<ProductModel> list = data
          .map<ProductModel>((e) => ProductModel.fromJson(e))
          .toList();
      print(res.statusCode);

      if (category == "food") {
        cropList = list;
      } else if (category == "machinery") {
        machineryList = list;
      } else if (category == "animal") {
        animalList = list;
      }
    }

    isLoading = false;
    notifyListeners();
  }

  void selectCrop(int id) {
    selectedCropId = id;
    notifyListeners();
  }

  void selectMachinery(int id) {
    selectedMachineryId = id;
    notifyListeners();
  }

  void selectAnimal(int id) {
    selectedAnimalId = id;
    notifyListeners();
  }
}
