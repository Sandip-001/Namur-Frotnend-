import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/product_model_api.dart';
import '../models/sub_category_model.dart';
import '../services/category_service.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _service = CategoryService();

  // DATA
  List<CategoryModel> categories = [];
  List<SubCategoryModel> subCategories = [];
  Map<int, List<ProductModel>> productsBySubCategory = {};

  // LOADING STATES
  bool isCategoryLoading = false;
  bool isSubCategoryLoading = false;
  bool isProductLoading = false;

  // ---------------- FETCH CATEGORY LIST ----------------
  Future fetchCategories() async {
    isCategoryLoading = true;
    notifyListeners();

    try {
      categories = await _service.getCategories();
    } catch (e) {
      print("Category Error: $e");
    }

    isCategoryLoading = false;
    notifyListeners();
  }

  // ---------------- FETCH SUBCATEGORY LIST ----------------
  Future<void> loadSubCategories(int categoryId) async {
    isSubCategoryLoading = true;
    notifyListeners();

    try {
      subCategories = await _service.fetchSubCategories(categoryId);
    } catch (e) {
      print("SubCategory Error: $e");
    }

    isSubCategoryLoading = false;
    notifyListeners();
  }

  // ---------------- FETCH PRODUCTS FOR EACH TAB ----------------
  Future<void> loadProductsForTab(int subCategoryId) async {
    isProductLoading = true;
    notifyListeners();

    try {
      productsBySubCategory[subCategoryId] = await _service.fetchProducts(
        subCategoryId,
      );
    } catch (e) {
      print("Products Error: $e");
    }

    isProductLoading = false;
    notifyListeners();
  }
}
