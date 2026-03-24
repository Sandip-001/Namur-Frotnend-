import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:the_namur_frontend/utils/api_url.dart';
import '../models/category_model.dart';
import '../models/product_model_api.dart';
import '../models/sub_category_model.dart';

class CategoryService {
  Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(Uri.parse(ApiConstants.getCategories));
    print('fetching categories');
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => CategoryModel.fromJson(e)).toList();
    } else {
      print(response.statusCode);
      throw Exception("Failed to fetch categories");
    }
  }

  // Fetch Subcategory List
  Future<List<SubCategoryModel>> fetchSubCategories(int categoryId) async {
    final url = Uri.parse(ApiConstants.subCategoryByCategory(categoryId));

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => SubCategoryModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch subcategories");
    }
  }

  // Fetch Products for each Sub-Category
  Future<List<ProductModel>> fetchProducts(int subCategoryId) async {
    final url = Uri.parse(ApiConstants.productsBySubCategory(subCategoryId));

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ProductModel.fromJson(e)).toList();
    } else {
      throw Exception("Failed to fetch products");
    }
  }
}
