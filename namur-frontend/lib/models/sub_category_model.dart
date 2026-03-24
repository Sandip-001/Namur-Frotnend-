// lib/models/sub_category_model.dart

class SubCategoryModel {
  final int id;
  final String name;
  final int categoryId;
  final String categoryName;

  SubCategoryModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'],
      name: json['name'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
    );
  }
}
